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
      @records = Array.new
      @errors = Hash.new
      @selections = Hash.new
      @selected_pairs = Hash.new
      @selected_new_rec_ids = Array.new

      action_count = 0

      # get the model school
      # - creates/udpates @school, @school_year
      # errors are added to @errors and raised
      @school = lo_get_model_school(params)
      # get the subjects for the model school
      # @subjects = Subject.where(school_id: @school.id)
      @subjects = Subject.where(school_id: @school.id).includes(:discipline).order('disciplines.name, subjects.name')
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
      recs_from_upload = lo_get_file_from_upload(params)
      @records = recs_from_upload[:records]
      Rails.logger.debug("*** @records: #{@records.inspect}")
      @new_los_by_rec_clean = recs_from_upload[:new_los_by_rec]
      Rails.logger.debug("*** @new_los_by_rec_clean: #{@new_los_by_rec_clean.inspect}")
      @new_los_by_lo_code_clean = recs_from_upload[:new_los_by_lo_code]
      Rails.logger.debug("*** @new_los_by_lo_code_clean: #{@new_los_by_lo_code_clean.inspect}")

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
      @records_clean = @records.clone
      Rails.logger.debug("*** records count: #{@records.count}")
      @errors[:base] = 'Errors exist - see below!!!:' if dup_lo_descs_checked[:abort] || @error_list2.length > 0

      @stage = 3
      Rails.logger.debug("*** Stage: #{@stage}")
      # @new_recs_to_process = lo_get_new_recs_to_process(@records)

      step = 0
      # get the subject outcomes from the database for all subjects to process
      @old_los_by_lo_clean = lo_get_old_los
      @old_los_by_lo = @old_los_by_lo_clean.clone
      # @old_records_counts = @old_los_by_lo.count
      # @old_recs_to_process = Hash.new
      # @old_recs_to_process = lo_get_old_recs_to_process(@old_los_by_lo)

      step = 1
      # initial matching level from default value
      @match_level = DEFAULT_MATCH_LEVEL

      # process the new LO records in lo_code order, and generate all matching pairs for the current matching level.
      lo_matching_at_level(true)

      # if cannot update all records without matching, then start matching process on first subject.
      if !@allow_save
        @process_by_subject = @subjects.first
        @process_by_subject_id = @process_by_subject.id
        Rails.logger.debug("***")
        Rails.logger.debug("*** Running at @match_level #{@match_level}")
        Rails.logger.debug("***")
        lo_matching_at_level(true)
        # tighten @match_level until no deactivates or reactivates
        if !@allow_save && @loosen_level
          until @match_level <= 0
            @match_level -= 1
            Rails.logger.debug("***")
            Rails.logger.debug("*** Reducing @match_level to #{@match_level}")
            Rails.logger.debug("***")
            action_count = 0
            lo_matching_at_level(true)
            break if @allow_save || !@loosen_level
          end
        end
      else
        @process_by_subject = nil
      end


      if @errors.count == 0 && @error_list.length == 0 && !first_display

        # stage 5
        @stage = 5
      end

      Rails.logger.debug("*** Final Stage: #{@stage}")

      Rails.logger.debug("*** @errors: #{@errors.inspect}")
      @any_errors = @errors.count > 0 || @error_list.count > 0

      @rollback = false


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
      @records = Array.new
      @errors = Hash.new
      @selections = params['selections'].present? ? params['selections'].clone : Hash.new
      @selected_pairs = Hash.new
      @selected_new_rec_ids = Array.new
      @selections.each do |k,v|
        @selected_new_rec_ids << k.to_s if k != '-1'
      end


      action_count = 0

      # get the model school
      # - creates/udpates @school, @school_year
      @school = lo_get_model_school(params)
      # get the subjects for the model school
      @subjects = Subject.where(school_id: @school.id).includes(:discipline).order('disciplines.name, subjects.name')
      # if only processing one subject
      # - creates/updates @match_subject, @subject_id, @errors[:subject]
      @match_subject = lo_get_match_subject(params)
      @process_by_subject = lo_get_processed_subject(params)

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
      Rails.logger.debug("*** lo_get_file_from_hidden")
      recs_from_hidden = lo_get_file_from_hidden(params)
      @records_clean = recs_from_hidden[:records]
      @records = @records_clean.clone
      # @new_recs_to_process = lo_get_new_recs_to_process(@records)
      @new_los_by_rec_clean = recs_from_hidden[:los_by_rec]
      @new_los_by_lo_code_clean = recs_from_hidden[:new_los_by_lo_code]
      # @new_los_by_rec = @new_los_by_rec_clean.clone

      @stage = 3
      Rails.logger.debug("*** Stage: #{@stage}")

      step = 0
      # get the subject outcomes from the database for all subjects to process
      @old_los_by_lo = lo_get_old_los
      # @old_records_counts = @old_los_by_lo.count
      # @old_recs_to_process = Hash.new
      # @old_recs_to_process = lo_get_old_recs_to_process(@old_los_by_lo)
      # Rails.logger.debug("*** @old_records_counts #{@old_records_counts}")

      # @old_los_by_lo.each do |rk, old_rec|
      #   Rails.logger.debug("*** rk: #{rk}, old_rec: #{old_rec}")

      step = 1
      # development manual adjustmenmt of matching level from input field in matching page.
      @match_level = params[:match_level].present? ? params[:match_level].to_i : DEFAULT_MATCH_LEVEL

      # process the new LO records in lo_code order, and generate all matching pairs for the current matching level.
      lo_matching_at_level(false)

      step = 7
      Rails.logger.debug("*** step: #{step}, @allow_save: #{@allow_save}")
      if @allow_save
        ActiveRecord::Base.transaction do
          Rails.logger.debug("***")
          Rails.logger.debug("*** Update Subject Learning Outcomes")
          Rails.logger.debug("***")
          @pairs_matched.each_with_index do |pair, ix|
            rec = pair[0]
            matched_new_rec = pair[1].clone # only change state for this matching pair
            matched_weights = pair[2]

            Rails.logger.debug("*** Pair: #{matched_weights.inspect}")
            Rails.logger.debug("*** process? #{lo_subject_to_process?(rec[SubjectOutcomesController::COL_SUBJECT_ID]) && matched_weights[PARAM_ACTION].present?}")

            if lo_subject_to_process?(rec[SubjectOutcomesController::COL_SUBJECT_ID]) && matched_weights[PARAM_ACTION].present?
              Rails.logger.debug("*** Update old rec: #{rec}")
              case matched_weights[PARAM_ACTION]
              when :'=', :'~=', nil
                so = SubjectOutcome.find(rec[COL_DB_ID])
                so.active = true
                so.lo_code = matched_new_rec[:'LO Code:']
                so.description = matched_new_rec[:'Learning Outcome']
                so.marking_period = matched_new_rec[:mp_bitmap]
                so.save!
                action_count += 1
                action = 'Updated'
                Rails.logger.debug("*** Updated to : #{so.inspect}")
              when :'-'
                so = SubjectOutcome.find(rec[COL_DB_ID])
                so.active = false
                so.save!
                action_count += 1
                action = 'Removed'
                Rails.logger.debug("*** Pair Removed: #{so.inspect}")
              when :'^'
                so = SubjectOutcome.find(rec[COL_DB_ID])
                so.active = true
                so.save!
                action_count += 1
                action = 'Restored'
                Rails.logger.debug("*** Pair Restored: #{so.inspect}")
              when :'+'
                so = SubjectOutcome.new
                so.lo_code = rec[COL_OUTCOME_CODE]
                so.description = rec[COL_OUTCOME_NAME]
                so.subject_id = rec[COL_SUBJECT_ID].to_i
                so.marking_period = rec[COL_MP_BITMAP]
                so.save!
                action_count += 1
                action = 'Added'
                Rails.logger.debug("*** Pair Added: #{so.inspect}")
              when 'Mismatch'
                Rails.logger.debug("*** Pair Mismatch")
                raise("Attempt to update with Mismatch - item #{action_count+1}")
              else
                Rails.logger.debug("*** Pair Invalid LO")
                raise("Invalid subject outcome action: #{rec[PARAM_ACTION].inspect} - item #{action_count+1}")
              end
            end

          end
          Rails.logger.debug("***")
          Rails.logger.debug("*** Add unmatched Learning Outcomes ????? ")
          Rails.logger.debug("***")
          @records.each do |rec|
            if lo_subject_to_process?(rec[SubjectOutcomesController::COL_SUBJECT_ID])
              Rails.logger.debug("*** @records rec: #{rec.inspect}")
              case rec[PARAM_ACTION]
              when :'+'
                so = SubjectOutcome.new
                so.lo_code = rec[COL_OUTCOME_CODE]
                so.description = rec[COL_OUTCOME_NAME]
                so.subject_id = rec[COL_SUBJECT_ID].to_i
                so.marking_period = rec[COL_MP_BITMAP]
                so.save!
                action_count += 1
                action = 'Added'
              when '='
                # ignore
                # Rails.logger.debug("*** 'ignore' action")
              when 'Mismatch'
                raise("Attempt to update with Mismatch - item #{action_count+1}")
              else
                raise("Invalid subject outcome action - item #{action_count+1}")
              end
            end

          end
          # raise "Successful Test cancelled" if action_count > 0
        end # transaction
        @stage = 9
      else
        # @errors[:base] =  'Invalid Upload (only adds allowed) - Not Saved'
        @stage = 5
      end # if @allow_save

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
      if @stage == 9 && @process_by_subject.blank?
        format.html { render :action => "lo_matching_update" }
      else
        # get current subject
        current_subject_ix = 0
        @subjects.each_with_index do |subj, ix|
          if subj.id == @process_by_subject_id
            current_subject_ix = ix
            break
          end
        end
        # process_by_subject increment to next subject after update
        if @process_by_subject.present? && current_subject_ix == @subjects.length
          # at end of subjects, go to reporting page
          format.html { render :action => "lo_matching_update" }
        else
          if @stage == 9
            # process next subject
            @process_by_subject = @subjects[current_subject_ix+1]
            @process_by_subject_id = @process_by_subject.id
            Rails.logger.debug("***")
            Rails.logger.debug("*** Running at @match_level #{@match_level}")
            Rails.logger.debug("***")

            # clear out selections from prior subject submit
            @selections = Hash.new
          end

          # generate pairs for subject
          lo_matching_at_level(false)

          # tighten @match_level until no deactivates or reactivates
          # if @deactivate_count > 0 || @reactivate_count > 0
          if @stage < 10 && @loosen_level
            until @match_level <= 0
              @match_level -= 1
              Rails.logger.debug("***")
              Rails.logger.debug("*** Reducing @match_level to #{@match_level}")
              Rails.logger.debug("***")
              action_count = 0
              lo_matching_at_level(false)
              break if @allow_save || !@loosen_level
            end
          end # loosen level (and not done yet)
          format.html
        end
      end
    end

  end

  private

end
