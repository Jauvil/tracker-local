# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class SchoolAdministratorsController < ApplicationController
  load_and_authorize_resource
  before_action :set_school_and_school_year, only: %i[show users_with_missing_emails]
  before_action :set_count_ratings, only: %i[show]
  before_action :set_subjects_and_ratings, only: %i[show]
  before_action :set_users_with_missing_emails, only: %i[users_with_missing_emails]

  def index
    respond_to do |format|
      format.html
    end
  end
  # New UI - School Administrator Dashboard
  def show
    if @school.id.nil?
      flash[:alert] = 'Missing School'
    else
      @by_date = @subject_ratings.sort_by{|k,v| v[:last_rating_date].to_time}.reverse
      @by_lo_count = @subject_ratings.sort_by{|k,v| (v[:ratio])}.reverse
      @recent10 = User.where('(teacher=? OR counselor=? OR school_administrator=?) AND current_sign_in_at IS NOT NULL AND school_id=?', true, true, true, @school.id).order(:last_name, :first_name).order('current_sign_in_at DESC').limit(10)
    end

    respond_to do |format|
      format.html
      # format.json #?????
    end
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def create
    @school_administrator.set_unique_username
    @school_administrator.set_temporary_password

    respond_to do |format|
      if @school_administrator.save
       format.html { redirect_to(@school_administrator, :notice => 'School administrator was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def users_with_missing_emails
    @school_administrator = SchoolAdministrator.find(params[:id])
  end

  private

  def set_school_and_school_year
    @school = (@current_user.system_administrator? || @current_user.researcher?) ?
                  @current_school : School.includes(:school_year).find(@school_administrator.school_id)
    @school_year = @school.is_a?(School) ? @school.school_year : nil
  end

  def set_count_ratings
    @school_ratings = @school.is_a?(School) ? @school.count_ratings : nil
  end

  def set_subjects_and_ratings
    if @school.is_a?(School)
      @subjects = Subject.where(school_id: @school.id)
      @subject_ratings = Hash.new
      @subjects.each do |s|
        @current_sections = Section.where(school_year_id: @school.school_year_id, subject_id: s.id)
        @subject_ratings[s.id] = s.count_ratings_plus(section_ids: @current_sections.pluck(:id), school_year_starts_at: @school_year.starts_at)
      end
    else
      @subjects = []
      @subject_ratings = {}
      @current_sections = []
    end
  end

  def set_users_with_missing_emails
    if @school.is_a?(School)
      @users_with_blank_emails = @school.users.where('email = ? OR email IS NULL', '')
    else
      @users_with_blank_emails = []
    end
  end
end
