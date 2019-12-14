# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class TeachersController < ApplicationController
  load_and_authorize_resource

  TEACHER_PARAMS = [
    :first_name,
    :last_name,
    :email,
    :street_address,
    :city,
    :state,
    :zip_code
  ]

  def index
    respond_to do |format|
      format.html
      format.json
    end
  end

  # New UI - Teacher Dashboard
  def show
    current_sections = TeachingAssignment.where(teacher_id: @teacher.id).pluck(:section_id)
    @current_sections = Section.includes(:section_outcomes).where(id: current_sections).order(:position).references(:section_outcomes).current
    Rails.logger.debug("+++ current_sections #{@current_sections.inspect}")

    old_section = TeachingAssignment.where(teacher_id: @teacher.id).pluck(:section_id)
    @old_sections = Section.includes(:section_outcomes).where(id: old_section).order(:position).references(:section_outcomes).old
    Rails.logger.debug("+++ old_sections #{@old_sections.inspect}")


    current_sect_ids = []
    @teacher.teaching_assignments.each do |ta|
      current_sect_ids << ta.section_id if ta.section && @teacher.school.school_year_id == ta.section.school_year_id
    end

    # used for both overall student performance and section proficiency bars
    @ratings = SectionOutcomeRating.hash_of_section_outcome_rating_by_section(section_ids: current_sect_ids)

    unique_student_ids = Enrollment.where(section_id: current_sect_ids).pluck(:student_id).uniq
    Rails.logger.debug("*** unique_student_ids = #{unique_student_ids.inspect.to_s}")

    @students = Student.alphabetical.where(id: unique_student_ids)

    @student_ratings = SectionOutcomeRating.hash_of_students_rating_by_section(section_ids: current_sect_ids)


    # recent activity
    @recent10 = Student.where('current_sign_in_at IS NOT NULL AND id in (?)', unique_student_ids).order('current_sign_in_at DESC').limit(10)


    respond_to do |format|
      format.html
      # format.json #?????
    end
  end

  # to be replaced by the new UI User#new_staff
  # Note that creating a new teacher will also create a new user.
  def new
    respond_to do |format|
      format.html
    end
  end

  # to be replaced by the new UI Users#create_staff
  # Note that creating a new teacher will also create a new user.
  def create
    @teacher.set_unique_username
    @teacher.set_temporary_password

    respond_to do |format|
      if @teacher.save
        format.html { redirect_to(@teacher, notice: 'Teacher successfully created!') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    respond_to do |format|
      if @teacher.update_attributes(teacher_params)
        format.html { redirect_to @teacher, notice: "Teacher successfully updated!" }
      else
        format.html { render action: "new" }
      end
    end
  end

  def tracker_usage
    # currently for all teacher in only one school
    @school = get_current_school
    current_section_ids = Section.where(school_year_id: @school.school_year_id).pluck(:id)
    if @school.has_flag?(School::USER_BY_FIRST_LAST)
      order_clause = "users.first_name, users.last_name"
    else
      order_clause = "users.last_name, users.first_name"
    end
    @teaching_assignments = TeachingAssignment.includes(:section, :teacher).where(section_id: current_section_ids).order("sections.line_number")
    @teachers = Teacher.where(id: @teaching_assignments.pluck(:teacher_id).uniq).order(order_clause)
    @taHash = Hash.new {|h,k| h[k] = {} }
    @teaching_assignments.each do |ta|
      sectHash = Hash.new
      sectHash[:id] = ta.section.id
      sectHash[:subj] = ta.section.name
      sectHash[:line] = ta.section.line_number
      sectHash[:eso_count] = ta.section.all_evidence_section_outcomes_count
      sectHash[:esor_count] = ta.section.rated_evidence_section_outcomes_count
      sectHash[:so_count] = ta.section.section_outcomes.count
      sectHash[:sor_count] = ta.section.rated_section_outcomes_count
      @taHash[ta.teacher_id][ta.section_id] = sectHash
    end
    respond_to do |format|
      format.html
    end
  end

  private

  def teacher_params
    params.require('teacher').permit(TEACHER_PARAMS)
  end

end
