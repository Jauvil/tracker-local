# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class SubjectOutcomesController < ApplicationController

  include SubjectOutcomesHelper

  SUBJECT_OUTCOME_PARAMS = [
    :section_id
  ]

  def index
    #
    # todo - remove this code - dead code - uses with_permissions_to from declarative_authorization gem
    @subject_outcomes = SubjectOutcome.with_permissions_to :read
  end

  def new
    @subject_outcome = SubjectOutcome.new
    @subjects = Subject.all
  end

  def create
    @subject_outcome = SubjectOutcome.new(subject_outcome_params)
    @subjects = Subject.all #with_permissions_to(:manage_subject_outcomes)
    respond_to do |format|
      if @subject_outcome.save
        format.html { redirect_to new_section_outcome_path(:section_id => params[:section_id]) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @subject_outcome = SubjectOutcome.find_by_id(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def update
    @subject_outcome = SubjectOutcome.find_by_id(params[:id])

    respond_to do |format|
      if @subject_outcome.update_attributes(subject_outcome_params)
        format.html { redirect_to session[:return_to], :notice => 'Learning Outcome was successfully updated.' }
      else
        format.html { render :action => :edit }
      end
    end
  end


  # GET edit_curric_los will initiatiate the update LOs from curriculum App to Model School (for new year rollover)
  # This respond with the list of subjects for the subject selection dropdown (or all subjects)
  def edit_curric_los
    Rails.logger.debug("*** edit_curric_los")
    authorize! :edit_curric_los, SubjectOutcome # only system admins can do this ?
    Rails.logger.debug("*** authorized!")
    @school = lo_get_model_school(params)
    Rails.logger.debug("*** @school: #{@school.inspect}")
    # get all (active) Tracker subjects, in the standard listing order
    @subjects = Subject.where(school_id: @school.id).includes(:discipline).order('disciplines.name, subjects.name')
    Rails.logger.debug("*** @subjects: #{@subjects.pluck(:name)}")

    # get all curriculum versions from curriculum for this curriculum code.
    get_curriculum_versions
    @version_errors = []

    # let users select the version of the curriculum that they wish to use.
    #    Note: dropdown should have current version as the pre-selected default value.
    #    Note: Confirm with user (javascript) if version number changes.
    #    Note: If no version Change, Are you sure you wish to do a mid year update (not available yet)
    if @curriculum_versions_response['success']
      @curriculum_versions = @curriculum_versions_response['versions']
      @curriculum_versions.push('v02') # This is a hack for developement purposes.
      if @curriculum_versions.length <= 1 && @school['curr_version_code'] == @curriculum_versions.first
        @version_errors = ['Are you sure you wish to do a mid year update, there are no new Curriculum versions']
      end
    end
  end


  # new UI, Get the LOs from curriculum App to Model School (for new year rollover)
  # see app/helpers/users_helper.rb for helper functions
  def update_curric_los
    Rails.logger.debug("*** update_curric_los")
    authorize! :update_curric_los, SubjectOutcome # only system admins can do this ?
    Rails.logger.debug("*** authorized!")
    Rails.logger.debug("*** params: #{params.inspect}")
    @rollback = false
    # begin

      # get the model school
      @school = lo_get_model_school(params)
      Rails.logger.debug("*** @school: #{@school.inspect}")
      # get the subjects for the model school
      # get all (active) Tracker subjects, in the standard listing order (Discipline and Subject names)
      if params[:subject_id].present?
        # ToDo: use strong params, and validate this is an integer
        @subjects = Subject.where(school_id: @school.id, id: params[:subject_id]).includes(:discipline)
      else
        @subjects = Subject.where(school_id: @school.id).includes(:discipline).order('disciplines.name, subjects.name')
      end
      Rails.logger.debug("*** @subjects: #{@subjects.pluck(:name)}")

      @errors = Hash.new
      @error_list = Hash.new
      @records = Array.new

      @prior_subject = nil
      @count_errors = 0
      @count_updates = 0
      @count_adds = 0
      @count_deactivates = 0
      @count_updated_subjects = 0

      # ToDo: This entire update should probably be wrapped in a transaction

      if @school['curr_version_code'] == params['version']
        # If no curriculum version change, then tell user mid year update is not available yet (see rake process).
        @version_errors = ['Mid year update is not available yet']
      else
        # Get the curriculum subjects for this curriculum & version from the model school record
        #   - consider getting curriculum subjects for previous version if version change
        # Note: LOs can be moved into another Tracker subject (currently between grade bands in same subject)

        # If curriculum version change, then update the model school record with the new version information.
        @version_errors = ['Updating Model School Record with the New Curriculum Version']

        if @subjects.count > 1
          get_curriculum_subjects
        else
          get_curriculum_subject(@subjects.first.curr_subject_id)
        end
        
        Rails.logger.debug("*** Starting loop through (chosen or all) Model School subjects")
        @subjects.each do |subj|
          Rails.logger.debug("*** Subject: #{subj.name}, #{subj.inspect}")
          # Get Curriculum Subject and Curriculum Grade Band from Subject Record
          matching_curriculum_subject = @curriculum_subjects_hash[subj.curr_subject_id]
          subject_matched = subject_matched?(matching_curriculum_subject, subj)
          if subject_matched
            if !matching_curriculum_subject['active']
              #   if curriculum subject or grade band are deactivated, deactivate Subject and its LOs in Tracker
              deactivate_tracker_subject_and_its_los(subj)
            else
              #    Create a hash of Curriculum Los for this subject (hash by curr_lo_tree_id)
              #    consider also getting the Curriculum Los for this subject for the previous version on version change
              get_curriculum_los(matching_curriculum_subject, subj.curr_grade_band_id)
              # Loop through Tracker LOs for Subject
              SubjectOutcome.where(subject_id: subj.id).order(:lo_code).each do |rec|
                # Look up Curriculum LO from SubjectOutcome (curriculum_tree_id)
                #   Note: if version changed, then be sure to determine the new LO from old_tree_id
                #     - The list of updated LO(s) will have old_tree_id = tracker curriculum_tree_id 
                #                                 ### old_tree_id is nil for now from Curriculum ###
                #     - be sure to put in tests for this !!
                matched_curriculum_lo = @curriculum_los_hash[rec.curriculum_tree_id]
                old_rec = {}
                if matched_curriculum_lo
                  old_rec = set_old_rec_data(rec, matched_curriculum_lo)
                  rec.update(
                    curriculum_tree_id: matched_curriculum_lo['tree_id'],
                    description: matched_curriculum_lo['lo_description']['en'],
                    lo_code: matched_curriculum_lo['lo_code'],
                    marking_period: matched_curriculum_lo['semester']
                  )
                else
                  #   If tracker LO is not in Curriculum (note version changing), mark the Tracker LO as deactivated
                  rec.active = false
                  #   - Note: indicate deactivated in output report
                end
                update_tracker_lo(rec, rec.id, old_rec)
                matched_curriculum_lo['matched'] = true 
              end # end of loop through Tracker Model School Subject Outcomes for subject subj
            end

            #   Loop through all unmatched LOs for subject subj (in Curriculum hash)
            #   For each unmatched LO add new LOs, Call create_tracker_lo(curriculum_tree_id)  (see below )
            create_new_curriculum_los_in_Tracker(@curriculum_los_hash, subj)

            # Mark curriculum Subject in hash as matched
            matching_curriculum_subject['matched'] = true

          else # Subject not matched!
            ### Deactivate subj and all its LOs
            deactivate_tracker_subject_and_its_los(subj)
          end
          
        end # end of loop through subjects

        # Process all unmatched Subjects in Curriculum Subjects Hash
        #   Add new subject and its learning outcomes.
        #     - Create a subject in Tracker and call create_tracker_lo (see below) for all LOs in curriculum
        @curriculum_subjects_hash.values.each do |curriculum_subject|
          if !curriculum_subject['matched']
            ### Create this subject in Tracker, and create all its LOs in Tracker.
            curriculum_subject['grade_bands'].each do |grade_band|
              create_new_tracker_subject_and_los(curriculum_subject, grade_band)
            end
            curriculum_subject['matched'] = true
          end
        end

      end # Checking if versions are same or not condition

      # semester is in Tree code, but not in displayed code
      #   - what is purpose of year long and semester 1 and 2 in LO Row in tracker.
      # full year
      # schools synched for capstones

      Rails.logger.debug("*** @errors.count #{@errors.count}")
      Rails.logger.debug("*** @count_errors #{@count_errors}")
      Rails.logger.debug("*** @count_updates #{@count_updates}")
      Rails.logger.debug("*** @count_adds #{@count_adds}")
      Rails.logger.debug("*** @count_deactivates #{@count_deactivates}")

    # rescue => e
    #   msg_str = "ERROR: update_curric_los Exception #{e.message}"
    #   Rails.logger.error(msg_str)
    #   flash[:alert] = msg_str[0...50]
    #   @rollback = true
    # end

  end # upload_LO_file

  private

  def subject_outcome_params
    params.require(:subject_outcome).permit(SUBJECT_OUTCOME_PARAMS)
  end

  def create_new_tracker_subject_and_los(curriculum_subject, grade_band)
    new_tracker_subject = Subject.new
    name = get_curriculum_subject_name(curriculum_subject, grade_band)
    new_tracker_subject.update(
      name: name,
      school_id: @school.id,
      discipline_id: Discipline.where(name: 'Others').first.id,
      active: true,
      curr_tree_type_id: curriculum_subject['tree_type_id'],
      curr_subject_code: curriculum_subject['code'],
      curr_subject_id: curriculum_subject['id'],
      curr_grade_band_id: grade_band['id'],
      curr_grade_band_code: grade_band['code'],
      curr_grade_band_number: grade_band['min_grade']
    )
    get_curriculum_los(curriculum_subject, new_tracker_subject.curr_grade_band_id)
    create_new_curriculum_los_in_Tracker(@curriculum_los_hash, new_tracker_subject)
  end

  def get_curriculum_versions
    @curriculum_versions_response = Curriculum::Client.get_curriculum_versions(
      encode_token, 
      @school['curriculum_code']
    )
  end

  def get_curriculum_subjects
    @curriculum_subjects_response = Curriculum::Client.subjects(
      encode_token, 
      @school['curr_tree_type_id']
    )
    hash_curriculum_subjects
  end

  def get_curriculum_subject(subject_id)
    @curriculum_subjects_response = Curriculum::Client.subject(
      encode_token, 
      @school['curr_tree_type_id'],
      subject_id
    )
    hash_curriculum_subjects
  end

  def hash_curriculum_subjects
    if @curriculum_subjects_response['success']
      @curriculum_subjects = @curriculum_subjects_response['subjects']
      @curriculum_subjects_hash = {}
      @curriculum_subjects.each do |subject|
        subject['matched'] = false
        @curriculum_subjects_hash[subject['id']] = subject
      end
    else
      @curriculum_subjects_hash = {}
    end
  end

  def get_curriculum_los(subject, grade_band_id)
    @curriculum_los_response = Curriculum::Client.learning_outcomes(
      encode_token, 
      subject['tree_type_id'], subject['id'], 
      grade_band_id
    )
    hash_curriculum_subject_los
  end

  def hash_curriculum_subject_los
    if @curriculum_los_response['success']
      @curriculum_los = @curriculum_los_response['learning_outcomes']
      @curriculum_los_hash = {}
      @curriculum_los.each do |curriculum_lo|
        curriculum_lo['matched'] = false
        @curriculum_los_hash[curriculum_lo['tree_id']] = curriculum_lo
      end
    else
      @curriculum_los_hash = {}
    end
  end

  def encode_token
    JWT.encode({email: current_user.email}, secrets['json_api_key'])
  end

  def subject_matched?(curriculum_subject, tracker_subject)
    subject_matched = false
    if curriculum_subject
      curriculum_subject['grade_bands'].each do |grade_band|
        get_curriculum_subject_name(curriculum_subject, grade_band)
        if @curriculum_subject_name == tracker_subject.name
          subject_matched = true
        end
      end
    end
    subject_matched
  end

  def get_curriculum_subject_name(curriculum_subject, grade_band)
    curriculum_subject_name = "#{curriculum_subject['versioned_name']['en']}" 
    curriculum_grade_code = " #{grade_band['code']}"
    @curriculum_subject_name = curriculum_subject_name + curriculum_grade_code
  end

  def deactivate_tracker_subject_and_its_los(tracker_subject)
    tracker_subject.active = false
    tracker_subject_los = tracker_subject.subject_outcomes
    if !tracker_subject_los.empty?
      tracker_subject_los.each do |tracker_lo|
        tracker_lo.active = false
      end
    end
  end

  def create_new_curriculum_los_in_Tracker(los_hash, tracker_subject)
    los_hash.values.each do |curriculum_lo|
      if !curriculum_lo['matched']
        create_tracker_lo(curriculum_lo, tracker_subject)
        curriculum_lo['matched'] = true
      end
    end
  end

  def create_tracker_lo(curriculum_lo, tracker_subject)
    lo = SubjectOutcome.new
    lo.update(
      subject_id: tracker_subject.id,
      curriculum_tree_id: curriculum_lo['tree_id'],
      description: curriculum_lo['lo_description']['en'],
      lo_code: curriculum_lo['lo_code'],
      marking_period: curriculum_lo['semester']
    )
    old_rec = set_old_rec_data(lo, curriculum_lo)
    update_tracker_lo(lo, lo.id, old_rec)
  end

  def update_tracker_lo(rec, model_school_subject_outcome_id, old_rec={})
    # to deactivate or update description of a tracker LO
    # If curriculum deactivated the LO
    #   Deactivate Tracker Model School LO
    #     references will be able to see this is deactivated.
    #   Else if Active Curriculum LO
    #     Update the Tracker Model School LO (description & ??)

    # Output matching LO Records to output report
    # ToDo: refactor records to also include matched curriculum fields
    # ToDo: Make report output nicer.
    # ToDo: give navigation at top and bottom of report for rerunning.
    # ToDo: check deactivated flag on rec and report on deactivations.
    @records << {
      discipline: rec.subject.discipline.name,
      subject: "#{rec.subject.name} #{old_rec['subject_name']}",
      grade:  "#{rec.subject.name.last} #{old_rec['grade']}",
      marking_period: "#{rec.marking_period} #{old_rec['marking_period']}",
      lo_code: "#{rec.lo_code} #{old_rec['lo_code']}",
      old_lo_desc: "#{old_rec['description']}",
      lo_desc: "#{rec.description}",
      errors: "#{rec.errors.full_messages.join(', ')}"
    }
  end

  def set_old_rec_data(tracker_lo, curriculum_lo)
    old_lo = tracker_lo.attributes
    # old_lo['description'] = "testing"
    # grade = tracker_lo.subject.name.last
    old_lo['subject_name'] = ''
    # subject_name = tracker_lo.subject.name ### Explain why Subject name might not be different

    if curriculum_lo['lo_description']['en'] == old_lo['description']
      old_lo['description'] = ''
    end

    if curriculum_lo['lo_code'] == old_lo['lo_code']
      old_lo['lo_code'] = ''
    else
      old_lo['lo_code'] = "Was(#{old_lo['lo_code']})"
    end

    if curriculum_lo['semester'] == old_lo['marking_period']
      old_lo['marking_period'] = ''
    else
      old_lo['marking_period'] = "Was(#{old_lo['marking_period']})"
    end

    old_lo
  end

end
