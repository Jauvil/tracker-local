# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class SubjectOutcomesController < ApplicationController

  include SubjectOutcomesHelper

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
    @subject_outcome = SubjectOutcome.new(params[:subject_outcome])
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
      if @subject_outcome.update_attributes(params[:subject_outcome])
        format.html { redirect_to session[:return_to], :notice => 'Learning Outcome was successfully updated.' }
      else
        format.html { render :action => :edit }
      end
    end
  end


  # new UI, upload LOs from curriculum spreadsheet to Model School (for new year rollover)
  # new UI HTML post method
  # Bulk Upload LOs file
  # stage 2 - reads csv file in and errors found within spreadsheet
  # stage 3 - reads csv file in and errors found against database
  # stage 4 - reads csv file and performs model validation of each record
  # stage 5 - updates records within a transaction - can upload again if errors
  # see app/helpers/users_helper.rb for helper functions
  def upload_lo_file
    authorize! :upload_lo, SubjectOutcome
    step = 0
    begin

      first_display = (request.method == 'GET' && params['utf8'].blank?)

      @stage = 1
      @errors = Hash.new
      @records = Array.new

      @mismatch_count = 0
      @add_count = 0
      @do_nothing_count = 0
      @reactivate_count = 0
      @deactivate_count = 0

      @pairs_filtered = Array.new
      action_count = 0

      # get the model school
      # - creates/udpates @school, @school_year
      # errors are added to @errors and raised
      @school = lo_get_model_school(params)
      # get the subjects for the model school
      @subjects = Subject.where(school_id: @school.id)
      # if only processing one subject
      # - creates/updates @match_subject, @subject_id
      # errors are added to @errors and raised
      @match_subject = lo_get_match_subject(params)

      if params['file'].blank? && !first_display
        @errors[:filename] = "Error: Missing Curriculum (LOs) Upload File."
        raise @errors[:filename]
      end

      if first_display
        @errors[:filename] = "Info: First Display"
        raise @errors[:filename]
      end

      @stage = 2
      Rails.logger.debug("*** Stage: #{@stage}")

      Rails.logger.debug("*** create subject hashes")
      @subject_ids = Hash.new
      @subject_names = Hash.new
      @subjects.each do |s|
        @subject_ids[s.id] = s if !@subject_id.present? || (@subject_id.present? && @subject_id == s.id) # IDs of all subjects to process
        @subject_names[s.name] = s
      end

      # create hash of new LO records from uploaded csv file
      @new_los_by_rec = lo_get_file_from_upload(params)

      # Check for duplicate LO codes in uploaded file
      @error_list = Hash.new
      # check for file duplicate LO Codes
      dup_lo_code_checked = validate_dup_lo_codes(@records)
      @error_list = dup_lo_code_checked[:error_list]
      Rails.logger.debug("*** @error_list: #{@error_list.inspect}")
      @records = dup_lo_code_checked[:records]
      Rails.logger.debug("*** records count: #{@records.count}")
      @errors[:base] = 'Errors exist - see below!!!:' if dup_lo_code_checked[:abort] || @error_list.length > 0

      # Check for duplicate LO descriptions in uploaded file
      @error_list2 = Hash.new
      # check for file duplicate LO Descriptions
      dup_lo_descs_checked = validate_dup_lo_descs(@records)
      @error_list2 = dup_lo_descs_checked[:error_list]
      Rails.logger.debug("*** @error_list2: #{@error_list2.inspect}")
      @records = dup_lo_descs_checked[:records]
      Rails.logger.debug("*** records count: #{@records.count}")
      @errors[:base] = 'Errors exist - see below!!!:' if dup_lo_descs_checked[:abort] || @error_list2.length > 0

      @stage = 3
      Rails.logger.debug("*** Stage: #{@stage}")

      step = 1
      # get the subject outcomes from the database for all subjects to process
      @old_los_by_lo = lo_get_old_los
      Rails.logger.debug("*** Subject Outcomes read from Database (count): #{@old_los_by_lo.count}")
      @old_records_counts = @old_los_by_lo.count

      # initial matching level from default value
      @match_level = DEFAULT_MATCH_LEVEL

      # process the database records in lo_code order, and generate all matching pairs for the current matching level.

      step = 2
      # no matching pairs from matching form, so set to empty array
      @pairs_matched = []

      step = 3
      # @pairs_matched set with any matching new records for each old record (at @match_level)
      lo_get_matches_for_old

      step = 4
      lo_process_pairs

      step = 5
      lo_add_unmatched

      @match_count = @pairs_matched.count
      Rails.logger.debug("*** @match_count: #{@match_count}")

      Rails.logger.debug("*** database records count: #{@old_los_by_lo.count}")
      Rails.logger.debug("*** csv records read count: #{@records.count}")
      Rails.logger.debug("*** pairs_filtered count: #{@pairs_filtered.count}")
      Rails.logger.debug("*** match_count : #{@match_count}")
      Rails.logger.debug("*** mismatch_count : #{@mismatch_count}")
      Rails.logger.debug("*** not_add_count : #{@not_add_count}")
      Rails.logger.debug("*** add_count : #{@add_count}")
      Rails.logger.debug("*** do_nothing_count : #{@do_nothing_count}")
      Rails.logger.debug("*** reactivate_count : #{@reactivate_count}")
      Rails.logger.debug("*** deactivate_count : #{@deactivate_count}")


      if @errors.count == 0 && @error_list.length == 0 && !first_display

        # stage 5
        @stage = 5
      end

      Rails.logger.debug("*** Final Stage: #{@stage}")

      Rails.logger.debug("*** @errors: #{@errors.inspect}")
      @any_errors = @errors.count > 0 || @error_list.count > 0

      @rollback = false


      @allow_save_all = true
      Rails.logger.debug("*** @do_nothing_count: #{@do_nothing_count}")
      Rails.logger.debug("*** @add_count: #{@add_count}")
      @allow_save_all = false if @records.count != @do_nothing_count + @add_count
      @allow_save_all = false if @deactivate_count > 0
      @allow_save_all = false if @reactivate_count > 0

    rescue => e
      if @errors[:filename] == "Info: First Display"
        @errors[:filename] = nil
        # Ignore this, first display where user is asked filename
      else
        msg_str = "ERROR: lo_matching Exception at @stage: #{@stage}, step #{step}, item #{action_count+1} - #{e.message}"
        @errors[:base] = append_with_comma(@errors[:base], msg_str)
        Rails.logger.error(msg_str)
        flash.now[:alert] = msg_str
        @stage = 5
      end
    end


    respond_to do |format|
      if @stage == 1 || @any_errors
        format.html
      else
        format.html { render :action => "lo_matching" }
      end
    end

  end # upload_LO_file

  # new UI, matching process for Bulk LO Upload
  # new UI HTML post method
  def lo_matching
    authorize! :upload_lo, SubjectOutcome
    step = 0
    begin
      @stage = 1
      @errors = Hash.new
      @records = Array.new

      @mismatch_count = 0
      @add_count = 0
      @do_nothing_count = 0
      @reactivate_count = 0
      @deactivate_count = 0

      action_count = 0

      @pairs_filtered = Array.new

      # get the model school
      # - creates/udpates @school, @school_year
      @school = lo_get_model_school(params)
      # get the subjects for the model school
      @subjects = Subject.where(school_id: @school.id)
      # if only processing one subject
      # - creates/updates @match_subject, @subject_id, @errors[:subject]
      @match_subject = lo_get_match_subject(params)

      @stage = 2
      Rails.logger.debug("*** Stage: #{@stage}")

      Rails.logger.debug("*** create subject hashes")
      @subject_ids = Hash.new
      @subject_names = Hash.new
      @subjects.each do |s|
        @subject_ids[s.id] = s if !@subject_id.present? || (@subject_id.present? && @subject_id == s.id) # IDs of all subjects to process
        @subject_names[s.name] = s
      end

      # get records and hash of new LO records from hidden variables (params)
      recs_from_hidden = lo_get_file_from_hidden(params)
      @records = recs_from_hidden[:records]
      @new_los_by_rec = recs_from_hidden[:los_by_rec]

      @stage = 3
      Rails.logger.debug("*** Stage: #{@stage}")

      step = 1
      # get the subject outcomes from the database for all subjects to process
      @old_los_by_lo = lo_get_old_los
      Rails.logger.debug("*** Subject Outcomes read from Database (count): #{@old_los_by_lo.count}")
      @old_records_counts = @old_los_by_lo.count

      # @old_los_by_lo.each do |rk, old_rec|
      #   Rails.logger.debug("*** rk: #{rk}, old_rec: #{old_rec}")

      # development manual adjustmenmt of matching level from input field in matching page.
      @match_level = params[:match_level].present? ? params[:match_level].to_i : DEFAULT_MATCH_LEVEL

      # process the database records in lo_code order, and generate all matching pairs for the current matching level.

      step = 2
      # all pairs set as selected in matching form are set as matched in @new_los_by_rec and @old_los_by_lo
      @pairs_matched = lo_set_selections_as_matched

      step = 3
      # @pairs_matched set with any matching new records for each old record (at @match_level), ignoring any previously matched old records.
      lo_get_matches_for_old

      step = 4
      @pairs_filtered = Array.new
      lo_process_pairs

      step = 5
      lo_add_unmatched

      @match_count = @pairs_matched.count
      Rails.logger.debug("*** @match_count: #{@match_count}")

      # need to turn on is_matched logic in lo_matching.html.haml
      # need to turn on radio buttons
      # when is :matched set on new records (see lo_matching.html.haml, subject_outcome_helper.rb/lo_set_selections_as_matched)
      # matching on @old_los_by_lo gets matched groupings for display to user.  Note these need to be grouped by the UI.  Note these need to be presented to user for selection by radio buttons.
      # How are items matched in lo_set_selections_as_matched determined to not have radio buttons in UI

      Rails.logger.debug("*** @mismatch_count: #{@mismatch_count}")
      Rails.logger.debug("*** submit_action: #{params[:submit_action]}")
      Rails.logger.debug("*** Update? : #{@mismatch_count == 0 && params[:submit_action] == 'save_all'}")

      Rails.logger.debug("*** records count: #{@records.count}")
      Rails.logger.debug("*** pairs_filtered count: #{@pairs_filtered.count}")
      Rails.logger.debug("*** match_count : #{@match_count}")
      Rails.logger.debug("*** mismatch_count : #{@mismatch_count}")
      Rails.logger.debug("*** not_add_count : #{@not_add_count}")
      Rails.logger.debug("*** add_count : #{@add_count}")
      Rails.logger.debug("*** do_nothing_count : #{@do_nothing_count}")
      Rails.logger.debug("*** reactivate_count : #{@reactivate_count}")
      Rails.logger.debug("*** deactivate_count : #{@deactivate_count}")

      old_rec_actions = []

      @allow_save_all = true
      @allow_save_all = false if @records.count != @do_nothing_count + @add_count
      @allow_save_all = false if @deactivate_count > 0
      @allow_save_all = false if @reactivate_count > 0

      if params[:submit_action] == 'save_all' && !@allow_save_all
        raise("Error: cannot update - must currently only add learning outcomes.")
      end

      step = 7
      @records4 = []
      if @allow_save_all && params[:submit_action] == 'save_all'
        ActiveRecord::Base.transaction do
          old_rec_actions.each do |rec|
            # Rails.logger.debug("*** old rec: #{rec}")
            case rec[PARAM_ACTION]
            when :'-'
              so = SubjectOutcome.find(rec[COL_REC_ID])
              so.active = false
              so.save!
              action_count += 1
              action = 'Removed'
              @records4 << [so, 'Removed']
            when :'+'
              so = SubjectOutcome.find(rec[COL_REC_ID])
              so.active = true
              so.save!
              action_count += 1
              action = 'Restored'
              @records4 << [so, 'Restored']
            when ''
              # ignore
              # Rails.logger.debug("*** 'ignore' action")
            when 'Mismatch'
              raise("Attempt to update with Mismatch - item #{action_count+1}")
            else
              raise("Invalid subject outcome action - item #{action_count+1}")
            end

          end
          @records.each do |rec|
            Rails.logger.debug("*** new rec action: #{rec[PARAM_ACTION]}")
            case rec[PARAM_ACTION]
            when '+'
              so = SubjectOutcome.new
              so.lo_code = rec[COL_OUTCOME_CODE]
              so.description = rec[COL_OUTCOME_NAME]
              so.subject_id = rec[COL_COURSE_ID].to_i
              so.marking_period = rec[COL_MP_BITMAP]
              so.save!
              action_count += 1
              action = 'Added'
              @records4 << [so, 'Added']
            when '='
              # ignore
              # Rails.logger.debug("*** 'ignore' action")
            when 'Mismatch'
              raise("Attempt to update with Mismatch - item #{action_count+1}")
            else
              raise("Invalid subject outcome action - item #{action_count+1}")
            end

          end
          # raise "Successful Test cancelled" if action_count > 0
        end # transaction
        @stage = 9
      else
        # @errors[:base] =  'Invalid Upload (only adds allowed) - Not Saved'
        @stage = 5
      end # if update

    rescue => e
      msg_str = "ERROR: lo_matching Exception at step #{step} - item #{action_count+1} - #{e.message}"
      @errors[:base] = append_with_comma(@errors[:base], msg_str)
      Rails.logger.error(msg_str)
      flash.now[:alert] = msg_str
      @stage = 5
    end

    step = 8
    respond_to do |format|
      Rails.logger.debug("@stage: #{@stage}")
      if @errors.count > 0
        flash[:alert] = (@errors[:base].present?) ? @errors[:base] : 'Errors'
      end
      if @stage == 9
        format.html { render :action => "lo_matching_update" }
      else
        format.html
      end
    end

  end

  private

end
