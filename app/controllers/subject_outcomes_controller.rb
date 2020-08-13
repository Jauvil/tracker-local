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

      # ToDo: If curriculum version change, then update the model school record with the new version information.
      # ToDo: If no curriculum version change, then tell user mid year update is not available yet (see rake process).
      # ToDo: This entire update should probably be wrapped in a transaction
      if @school['curr_version_code'] == params['version']
        @version_errors = ['Mid year update is not available yet']
      else
        @version_errors = ['Updating Model School Record with the New Curriculum Version']
      end


      # Get the curriculum subjects for this curriculum & version from the model school record
      #   - consider getting curriculum subjects for previous version if version change
      get_curriculum_subjects
      count = 0
      Rails.logger.debug("*** Starting loop through (chosen or all) Model School subjects")
      @subjects.each do |subj|
        Rails.logger.debug("*** Subject: #{subj.name}, #{subj.inspect}")
        # Get Curriculum Subject and Curriculum Grade Band from Subject Record
        matching_curriculum_subject = @curriculum_subjects_hash[subj.curr_subject_id]
        subject_matched = subject_matched?(matching_curriculum_subject, subj)
        if subject_matched
          if !matching_curriculum_subject['active']
            # ToDo: if curriculum subject or grade band are deactivated
            #  - deactivate Subject and its LOs in Tracker
            #  - see update_tracker_lo(model_school_subject_outcome_id) below
          else
            # Create a hash of Curriculum Los for this subject (hash by curr_lo_tree_id)
            #  - consider also getting the Curriculum Los for this subject for the previous version on version change
            get_curriculum_learning_outcomes(matching_curriculum_subject, subj.curr_grade_band_id)
            # Loop through Tracker LOs for Subject
            SubjectOutcome.where(subject_id: subj.id).order(:lo_code).each do |rec|
              # Look up Curriculum LO from SubjectOutcome (curriculum_tree_id)
              #   Note: if version changed, then be sure to determine the new LO from old_tree_id
              #     - The list of updated LO(s) will have old_tree_id = tracker curriculum_tree_id
              #     - be sure to put in tests for this !!
              matched_curriculum_lo = @curriculum_learning_outcomes_hash[rec.curriculum_tree_id]
              if matched_curriculum_lo
                ### If the LO is matched, we update it!
                # Mark curriculum LO in hash as matched
                rec.update(
                  curriculum_tree_id: matched_curriculum_lo['tree_id'],
                  description: matched_curriculum_lo['lo_description']['en'],
                  lo_code: matched_curriculum_lo['lo_code']
                )
                matched_curriculum_lo['matched'] = true #is this the right place?
                update_tracker_lo(rec, rec.id)
                count += 1
              else
                # ToDo: If tracker LO is not in Curriculum (note version changing)
                #   - mark the Tracker LO as deactivated
                #   - Note: indicate deactivated in output report
              end
            end # end of loop through Tracker Model School Subject Outcomes for subject subj
          end
          #  Loop through all unmatched LOs for subject subj (in Curriculum hash)
          #  For each unmatched LO
          #    - To add new LOs, Call create_tracker_lo(curriculum_tree_id)  (see below )
          #    - Mark curriculum LO in hash as matched
          @curriculum_learning_outcomes_hash.values.each do |curriculum_learning_outcome|
            if !curriculum_learning_outcome['matched']
              create_tracker_lo(curriculum_learning_outcome, subj.id)
              count += 1
              curriculum_learning_outcome['matched'] = true
              matching_curriculum_subject['matched'] = true
            end
          end
        else
          ### Deactivate subj and all its LOs
          # If no matching subject in in Curriculum:
          #   Deactivate the subject and all of its LOs in Tracker
          #    - see: update_tracker_lo(rec, model_school_subject_outcome_id)
        end
        
        
        
        
      end # end of loop through subjects
      puts "count: #{count}".red

      # Process all unmatched Subjects in Curriculum Subjects Hash
      #   Add new subject and its learning outcomes.
      #     - Create a subject in Tracker and call create_tracker_lo (see below) for all LOs in curriculum
      @curriculum_subjects_hash.values.each do |curriculum_subject|
        if !curriculum_subject['matched']
          ### Create this subject in Tracker, and create all its LOs in Tracker.
        end
      end

      # Note: LOs can be moved into another Tracker subject (currently between grade bands in same subject)

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

  def update_tracker_lo(rec, model_school_subject_outcome_id)
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
      subject: "#{rec.subject.name}",
      grade:  "#{rec.subject.name.last}",
      marking_period: "#{rec.marking_period_string}",
      lo_code: "#{rec.lo_code}",
      lo_desc: "#{rec.description}",
      errors: "#{rec.errors.full_messages.join(', ')}"
    }

  end

  def create_tracker_lo(curriculum_learning_outcome, subject_id)
    learning_outcome = SubjectOutcome.new
    learning_outcome.subject_id = subject_id
    learning_outcome.curriculum_tree_id = curriculum_learning_outcome['tree_id']
    learning_outcome.description = curriculum_learning_outcome['lo_description']['en']
    learning_outcome.lo_code = curriculum_learning_outcome['lo_code']
    learning_outcome.save
    update_tracker_lo(learning_outcome, learning_outcome.id)
  end

  def get_curriculum_versions
    @curriculum_versions_response = Curriculum::Client.get_curriculum_versions(encode_token, @school['curriculum_code'])
  end

  def get_curriculum_subjects
    @curriculum_subjects_response = Curriculum::Client.subjects(encode_token, @school['curr_tree_type_id'])
    hash_curriculum_subjects
  end

  def hash_curriculum_subjects
    if @curriculum_subjects_response['success']
      @curriculum_subjects = @curriculum_subjects_response['subjects']
      # Create a hash of all Curriculum subjects , and add a field to indicate matched to existing Tracker subject
      @curriculum_subjects_hash = {}
      @curriculum_subjects.each do |curriculum_subject|
        curriculum_subject['matched'] = false
        @curriculum_subjects_hash[curriculum_subject['id']] = curriculum_subject
      end
    else
      @curriculum_subjects_hash = {}
    end
  end

  def get_curriculum_learning_outcomes(subject, grade_band_id)
    @curriculum_learning_outcomes_response = Curriculum::Client.learning_outcomes(encode_token, subject['tree_type_id'], subject['id'], grade_band_id)
    hash_curriculum_subject_learning_outcomes
  end

  def hash_curriculum_subject_learning_outcomes
    if @curriculum_learning_outcomes_response['success']
      @curriculum_learning_outcomes = @curriculum_learning_outcomes_response['learning_outcomes']
      @curriculum_learning_outcomes_hash = {}
      @curriculum_learning_outcomes.each do |curriculum_learning_outcome|
        curriculum_learning_outcome['matched'] = false
        @curriculum_learning_outcomes_hash[curriculum_learning_outcome['tree_id']] = curriculum_learning_outcome
      end
    else
      @curriculum_learning_outcomes_hash = {}
    end
  end

  def encode_token
    JWT.encode({email: current_user.email}, secrets['json_api_key'])
  end

  def subject_matched?(curriculum_subject, tracker_subject)
    subject_matched = false
    if curriculum_subject
      curriculum_subject['grade_bands'].each do |grade_band|
        if "#{curriculum_subject['versioned_name']['en']}" + " #{grade_band['code']}" == tracker_subject.name
          subject_matched = true
        end
      end
    end
    subject_matched
  end

end
