# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class SystemAdministratorsController < ApplicationController

  def show
    curriculums_response = Curriculum::Client.curriculums(session[:jwt_token])
    if curriculums_response['success']
      @curriculums = curriculums_response['curriculums']
      subjects_response = Curriculum::Client.subjects(session[:jwt_token], @curriculums.last['id'])
      if subjects_response['success']
        @subjects = subjects_response['subjects']
        learning_outcomes_response = Curriculum::Client.learning_outcomes(session[:jwt_token], @subjects.first['tree_type_id'], @subjects.first['id'], nil)
        @learning_outcomes = learning_outcomes_response['learning_outcomes']
      else
        @subjects = []
        @learning_outcomes = []
      end
    else
      @curriculums = []
      @subjects = []
      @learning_outcomes = []
    end
    
    authorize! :sys_admin_links, User
    @system_administrator = User.find(params[:id])
    @model_school = School.includes(:school_year).find(1)
    @school = get_current_school
    @schools = School.includes(:school_year).accessible_by(current_ability).order('name')
    respond_to do |format|
      format.html
    end
  end

  def system_maintenance
    authorize! :sys_admin_links, User
    respond_to do |format|
      format.html
    end
  end

  def system_users
    authorize! :sys_admin_links, User
    @model_school = School.find(1)
    @system_users = User.where("users.system_administrator = ? OR users.researcher = ?", true, true)
    Rails.logger.debug("*** users: #{@system_users.inspect}")
    respond_to do |format|
      format.html
    end
  end

  def new_system_user
    authorize! :sys_admin_links, User
    @user = User.new
    respond_to do |format|
      format.js
    end
  end

  def edit_system_user
    authorize! :sys_admin_links, User
    @user = User.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update_system_user
    authorize! :sys_admin_links, User
    @model_school = School.find(1)
    @user = User.find(params[:id])

    if params['role'] == 'system_administrator'
      # set_role(@user, 'system_administrator', true)
      # set_role(@user, 'researcher', false)
    elsif params['role'] == 'researcher'
      # set_role(@user, 'researcher', true)
      # set_role(@user, 'system_administrator', false)
    end
    # @user.assign_attributes(params[:user])
    @user.assign_attributes(user_params)
    respond_to do |format|
      if user_params[:email].blank? && @model_school.has_flag?(School::USERNAME_FROM_EMAIL)
        @user.errors.add(:email, "email is required")
        Rails.logger.error("*** @user.errors: #{@user.errors.inspect}")
        format.js
      else
        if @user.errors.count == 0
          @user.update_attributes(user_params)
          Rails.logger.error("*** after update_attributes @user.errors: #{@user.errors.inspect}")
        else
          Rails.logger.error("*** no update_attributes @user.errors: #{@user.errors.inspect}")
        end
        format.js
      end
    end
  end

  def users_with_missing_emails
    redirect_to root_path, alert: "You need to login to view this page" unless current_user.present? && current_user.system_administrator
    @users_with_missing_emails = User.where("email = '' OR email IS NULL")
    render 'school_staff/administrators/users_with_missing_emails'
  end

  def edit_user_email
    @user = User.find(params[:user_id])
    render 'school_staff/administrators/edit_user_email'
  end

  def update_user_email
    user_id = user_email_params.delete(:id)
    @user = User.find(user_id)
    begin
      if UpdateUserEmail.perform(@user, user_email_params)
        redirect_to users_with_missing_emails_system_administrators_path, notice: 'Successfully updated user email'
      else
        redirect_to system_administrator_edit_user_email_path(system_administrator_id: current_user.id, user_id: @user.id), alert: 'Error updating user email'
      end
    rescue UpdateUserEmail::EmailsNotMatchingError, UpdateUserEmail::InvalidEmailError => e
      redirect_to system_administrator_edit_user_email_path(system_administrator_id: current_user.id, user_id: @user.id), alert: e.message
    end
  end

  #####################################################################################
  protected

  # # cloned from users_controller !!!
  # def set_role(user_in, role, value)
  #   Rails.logger.debug("*** set_role(#{role}, #{value}")
  #   if !can?(:update, role.to_s.camelize.constantize)
  #     Rails.logger.error("ERROR - Not authorized to set #{role.to_s.camelize} role")
  #     user_in.errors.add(:base, "Not authorized to set #{role.to_s.camelize} role")
  #   else
  #     user_in.send(role+'=', value)
  #   end
  # end

  private

  def user_params
    params
        .require('user')
        .permit(
            :first_name,
            :last_name,
            :email,
            :street_address,
            :city,
            :state,
            :zip_code,
            :system_administrator,
            :researcher
        )
  end

  def user_email_params
    params.require(:user).permit(:id, :email, :email_confirmation)
  end

  def defined_role
    return 'system_administrator' if user_params[:system_administrator] == 'on'
    return 'researcher' if user_params[:researcher] == 'on'
    nil
  end

end
