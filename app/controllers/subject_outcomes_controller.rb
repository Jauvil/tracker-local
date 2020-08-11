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

    # ToDo: get all curriculum versions from curriculum for this curriculum code.
    # ToDo: let users select the version of the curriculum that they wish to use.
    #    Note: dropdown should have current version as the pre-selected default value.
    #    Note: Confirm with user (javascript) if version number changes.
    #    Note: If no version Change, Are you sure you wish to do a mid year update (not available yet)
    # ToDo:
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

      # ToDo: Get the curriculum subjects for this curriculum & version from the model school record
      #   - consider getting curriculum subjects for previous version if version change
      # ToDo: Create a hash of all Curriculum subjects , and add a field to indicate matched to existing Tracker subject


      Rails.logger.debug("*** Starting loop through (chosen or all) Model School subjects")
      @subjects.each do |subj|
        Rails.logger.debug("*** Subject: #{subj.name}, #{subj.inspect}")
        # Get Curriculum Subject and Curriculum Grade Band from Subject Record
        # ToDo: if curriculum subject or grade band are deactivated
        #  - deactivate Subject and its LOs in Tracker
        #  - see update_tracker_lo(model_school_subject_outcome_id) below
        # ToDo:  Create a hash of Curriculum Los for this subject (hash by curr_lo_tree_id)
        #  - consider also getting the Curriculum Los for this subject for the previous version on version change
        # Loop through Tracker LOs for Subject
        SubjectOutcome.where(subject_id: subj.id).order(:lo_code).each do |rec|
          # ToDo: Look up Curriculum LO from SubjectOutcome curr_lo_tree_id
          #   Note: if version changed, then be sure to determine the new LO from old_tree_id
          #     - The list of updated LO(s) will have old_tree_id = tracker curr_lo_tree_id
          #     - be sure to put in tests for this !!
          # ToDo: If tracker LO is not in Curriculum (note version changing)
          #   - mark the Tracker LO as deactivated
          #   - Note: indicate deactivated in output report
          update_tracker_lo(rec, nil)
          # ToDo: Mark curriculum LO in hash as matched
        end # end of loop through Tracker Model School Subject Outcomes for subject subj

        #  Loop through all unmatched LOs for subject subj (in Curriculum hash)
        #  For each unmatched LO
        #    - To add new LOs, Call create_tracker_lo(curriculum_tree_id)  (see below )
        #    - Mark curriculum LO in hash as matched

        #   Mark curriculum subject in hash as matched

        # If no matching subject in in Curriculum:
        #   Deactivate the subject and all of its LOs in Tracker
        #    - see: update_tracker_lo(rec, model_school_subject_outcome_id)
      end # end of loop through subjects


      # Process all unmatched Subjects in Curriculum Subjects Hash
      #   Add new subject and its learning outcomes.
      #     - Create a subject in Tracker and call create_tracker_lo (see below) for all LOs in curriculum

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
      grade:  "grade from tracker subject name",
      marking_period: "#{rec.marking_period_string}",
      lo_code: "#{rec.lo_code}",
      lo_desc: "#{rec.description}",
      errors: "#{rec.errors.full_messages.join(', ')}"
    }

  end

  def create_tracker_lo(curriculum_tree_id)
    # see update_tracker_lo
  end

end
