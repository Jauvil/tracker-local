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
  end


  # new UI, Get the LOs from curriculum App to Model School (for new year rollover)
  # see app/helpers/users_helper.rb for helper functions
  def update_curric_los
    Rails.logger.debug("*** update_curric_los")
    authorize! :update_curric_los, SubjectOutcome # only system admins can do this ?
    Rails.logger.debug("*** authorized!")
    Rails.logger.debug("*** params: #{params.inspect}")
    Rails.logger.debug("*** params: #{params.inspect}")
    @rollback = false
    # begin

      # get the model school
      @school = lo_get_model_school(params)
      Rails.logger.debug("*** @school: #{@school.inspect}")
      # get the subjects for the model school
      # ToDo: Set Subject.active to true on all subjects (currently all are nil) - to allow deactivating subjects
      # Note: This depends upon Tracker Subject file having the 5 curriculum fields in it
      #   pre-populated for the model school
      #   (curr_tree_type_code, curr_tree_type_id, curr_subject_code, curr_subj_id, curr_gb_id)
      # Note: this should normally be part of creating a new system's model school.
      # get all (active) Tracker subjects, in the standard listing order
      if params[:subject_id].present?
        # ToDo: use strong params, and validate this is an integer
        @subjects = Subject.where(school_id: @school.id, id: params[:subject_id]).includes(:discipline).order('disciplines.name, subjects.name')
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

      # # if only processing one subject
      # # - creates/updates @match_subject, @subject_id
      # @match_subject = @single_subject = lo_get_match_subject(params)

      # if @match_subject.present?
      #   Rails.logger.debug("*** starting update single subject: #{@match_subject.name}")
      #   process_subject(@match_subject)
      # else

      # get the curriculum subjects for this curriculum & version
      # Note: should this come from the model school record
      # Note: do all model school LO records need the curriculum and version or can that be removed?
      # ToDo: Put in Rapkat's code to pull in subjects from curriculum here
      # 1) create a hash of all Curriculum subjects , and add a field to indicate matched to existing Tracker subject


      Rails.logger.debug("*** Starting loop through all Model School subjects")
      @subjects.each do |subj|
        Rails.logger.debug("*** Subject: #{subj.name}, #{subj.inspect}")

        # match up tracker subject to curriculum subject
        # if matching subject in curriculum:
        #   Create a hash of Curriculum Los for this subject
        #   loop through Tracker LOs for Subject
        SubjectOutcome.where(subject_id: subj.id).order(:lo_code).each do |rec|
          #     Match the Tracker Model School LO to the curriculum LO
          #       ? Match by tree_id ?
          #       if version change then llook up old tree id
          #       !! tests for this !!
          #       Call update_tracker_lo
          #       Mark curriculum LO in hash as matched
          #     If no match, mark the Tracker LO as deactivated?
          #   Loop through all unmatched LOs in Curriculum hash
          #     Call create_tracker_lo to add as new LO
          #     Mark curriculum LO in hash as matched
          #   Mark curriculum subject in hash as matched
          # If no matching subject in in Curriculum:
          #   Deactivate the subject and all of its LOs in Tracker
          # ToDo: refactor records to also include matched curriculum fields
          # ToDo: Make report output nicer.
          # ToDo: give navigation at bottom of report for rerunning.
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
        # end of loop through subjects
        # Process all unmatched Subjects in Curriculum Subjects Hash
        #   Add new subject and its learning outcomes.
        #     - Create a subject in Tracker and call create_tracker_lo for all LOs in curriculum

        # ?? do we need to update School Subject Outcomes and Section Outcomes
        #   - middle of school year use mid year rake process
        # ?? Emily - will LOs be able to be moved into another subject
        #  - Can be moved between Grade bands.
        #  - which is a different subject in Tracker
        # semester is in Tree code, but not in displayed code
        #   - what is purpose of year long and semester 1 and 2 in LO Row in tracker.
        # full year
        # schools synched for capstones

        # assumption: Tracker Model School Subject Outcome is prepopulated with
        # - curriculum subject id and grade band id to know/confirm subject
        # - curriculum LO tree_id to match the LOs

        # def update_tracker_lo(model_school_subject_outcome_id)
        #   # to deactivate or update description of a tracker LO
        #   If curriculum deactivated the LO
        #     Deactivate Tracker Model School LO
        #       references will be able to see this is deactivated.
        #     Else if Active Curriculum LO
        #       Update the Tracker Model School LO (description & ??)

        # def create_tracker_lo(curriculum_tree_id)
      end
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

end
