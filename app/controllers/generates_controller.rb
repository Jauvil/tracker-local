# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
# generates_controller.rb
class GeneratesController < ApplicationController
  # Not hooked up to a database table / ActiveRecord model like the other controllers. Used to serve
  # semi-static pages that still need some server information.

  GENERATE_PARAMS = [
    :name,
    :subject_id,
    :subject_section_id,
    :grade_level,
    :section_id,
    :section_outcome_id,
    :student_id,
    :single_student_id,
    :marking_period,
    :start_date,
    :end_date,
    :details,
    :attendance_type_id,
    :user_type_staff,
    :user_type_students,
    :user_type_parents
  ]

  # new UI
  # Generate Form selecting options for generated listings
  # - listings - Toolkit - Generate Listings
  # GET "/generates/new"
  def new
    puts "+++ new generate report"
    authorize! :read, Generate
    @generate = Generate.new
    @section_id = params[:section_id] if params[:section_id]
    begin
      @section = Section.find(@section_id)
      Rails.logger.debug("*** current section = #{@section.name} - #{@section.line_number}")
    rescue => e
      Rails.logger.debug("*** NO current section")
      @section_id = params[:section_id]
    end
    @school = get_current_school
    if !@school.id.nil?
      @subjects = Subject.accessible_by(current_ability, :show).where(school_id: @school.id).order('subjects.name')
      @subject_sections = Section.accessible_by(current_ability, :show).includes(:subject).where(school_year_id: @school.school_year_id).order('subjects.name, sections.line_number')
      @marking_periods = Range::new(1,@school.marking_periods)
      if @school.has_flag?(School::USER_BY_FIRST_LAST)
        @school_students = Student.accessible_by(current_ability).order(:first_name, :last_name).where(school_id: @school.id)
      else
        @school_students = Student.accessible_by(current_ability).order(:last_name, :first_name).where(school_id: @school.id)
      end
      @school_year = SchoolYear.where(id: @school.school_year_id).first
      @range_start = @school_year.starts_at
      @range_end = @school_year.ends_at
      @attendance_types = AttendanceType.all_attendance_types.where(school_id: @school.id)
    end
    respond_to do |format|
      if !current_user
        Rails.logger.debug("*** no current user, go to root page")
        format.html { redirect_to root_path}
      elsif @school.id.nil?
        Rails.logger.debug("*** no current school, go to school select page")
        flash[:alert] = I18n.translate('errors.invalid_school_pick_one')
        format.html { redirect_to schools_path}
      else
        Rails.logger.debug("*** OK, default response")
        format.html #ToDo Not redirecting to CREATE GENERATE REPORT
      end
    end
  end


  # new UI
  # forward a report to run to proper controller action if valid parameters entered
  # otherwise send errors back to form for resubmission.
  # POST "/generates"
  def create
    puts "+++ create Generate Report"
    authorize! :read, Generate
    Rails.logger.debug("*** params: #{params.inspect}")
    # generate_params = params[:generate]
    @generate = Generate.new(generate_params)
    Rails.logger.debug ("@generate = #{@generate.inspect.to_s}")
    if @generate.valid?   #see validators/generate_validator.rb
      Rails.logger.debug("record is valid")
    else
      Rails.logger.debug("@generate.errors = #{@generate.errors.inspect.to_s}")
      Rails.logger.debug("record is NOT valid")
    end
    @section_id = params[:section_id] if params[:section_id]
    @section_id = @generate.section_id if @generate.section_id
    begin
      @section = Section.find(@section_id)
      Rails.logger.debug("*** current section = #{@section.name} - #{@section.line_number}")
    rescue => e
      Rails.logger.debug("*** NO current section")
      @section_id = params[:section_id]
    end
    @school = get_current_school
    if !@school.id.nil?
      @subjects = Subject.where(school_id: @school.id).order('subjects.name')
      @subject_sections = Section.includes(:subject).where(school_year_id: @school.school_year_id).order('subjects.name, sections.line_number')
      @marking_periods = Range::new(1,@school.marking_periods)
      if @school.has_flag?(School::USER_BY_FIRST_LAST)
        @school_students = Student.accessible_by(current_ability).order(:first_name, :last_name).where(school_id: @school.id)
      else
        @school_students = Student.accessible_by(current_ability).order(:last_name, :first_name).where(school_id: @school.id)
      end
      @range_start = generate_params[:start_date].truncate(10, omission: '')
      @range_end = generate_params[:end_date].truncate(10, omission: '')
      @attendance_types = AttendanceType.all_attendance_types.where(school_id: @school.id)
    end
    respond_to do |format|
      if !current_user
        format.html { redirect_to root_path}
      elsif @school.id.nil?
        flash[:alert] = I18n.translate('errors.invalid_school_pick_one')
        format.html { redirect_to schools_path}
      elsif @generate.errors.count > 0
        format.html
      else
        Rails.logger.debug("*** @generate.name: #{@generate.name}")
        format.html {redirect_to tracker_usage_teachers_path} if @generate.name == 'tracker_usage'
        format.html {redirect_to section_summary_outcome_section_path(@section.id)} if @generate.name == 'ss_by_lo'
        format.html {redirect_to section_summary_student_section_path(@section.id)} if @generate.name == 'ss_by_stud'
        format.html {redirect_to nyp_student_section_path(@section.id)} if @generate.name == 'nyp_by_stud'
        format.html {redirect_to nyp_outcome_section_path(@section.id)} if @generate.name == 'nyp_by_lo'
        format.html {redirect_to student_info_handout_section_path(@section.id)} if @generate.name == 'student_info'
        format.html {redirect_to student_info_handout_by_grade_sections_path()} if @generate.name == 'student_info_by_grade'
        format.html {redirect_to progress_rpt_gen_section_path(@section.id)} if @generate.name == 'progress_rpt_gen'
        format.html {redirect_to students_report_path('proficiency_bar_chart')} if @generate.name == 'proficiency_bars_by_student'
        format.html {redirect_to proficiency_bars_subjects_path} if @generate.name == 'proficiency_bars_by_subject'
        format.html {redirect_to progress_meters_subjects_path} if @generate.name == 'progress_meters_by_subject'
        # code to generate single student bar chart
        # format.html {redirect_to xxxxxx_path(@generate.student_id)} if @generate.name == 'proficiency_bars' && @generate.student_id != ''
        format.html {redirect_to create_report_card_path(grade_level: @generate.grade_level)} if @generate.name == 'report_cards'
        format.html {redirect_to account_activity_report_users_path(user_type_staff: @generate.user_type_staff, user_type_students: @generate.user_type_students, user_type_parents: @generate.user_type_parents, )} if @generate.name == 'account_activity'
        format.html {redirect_to section_attendance_xls_attendances_path()} if @generate.name == 'section_attendance_xls'
        format.html {redirect_to controller: :attendances, action: :attendance_report, subject_id: generate_params[:subject_id], subject_section_id: generate_params[:subject_section_id], start_date: @range_start, end_date: @range_end, attendance_type_id: generate_params[:attendance_type_id]} if @generate.name == 'attendance_report'
        format.html {redirect_to controller: :attendances, action: :student_attendance_detail_report, student_id: generate_params[:student_id], start_date: @range_start, end_date: @range_end, attendance_type_id: generate_params[:attendance_type_id], details: generate_params[:details]} if @generate.name == 'student_attendance_detail_report'
        format.html {redirect_to view_context.user_dashboard_path(current_user),
          alert: 'Invalid Report Chosen!'
        }
      end
    end
  end

  private

  def generate_params
    params.require(:generate).permit(GENERATE_PARAMS)
  end
end
