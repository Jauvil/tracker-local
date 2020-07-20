class Sso::AdminRegistrationsController < ApplicationController
  def show
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

  def create_system_user
    authorize! :sys_admin_links, User
    @model_school = School.find(1)
    @user = User.new(user_params)
    @user.errors.add(:base, 'Role is required!') if defined_role.nil?
    defined_role == 'researcher' ?
        @user.researcher = true : @user.system_administrator = true

    @user.set_unique_username
    @user.set_temporary_password

    if @user.save
      UserMailer.welcome_system_user(@user, get_server_config).deliver_now
      yield @user, user_params[:password] if block_given?
    end

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

  def defined_role
    return 'system_administrator' if user_params[:system_administrator] == 'on'
    return 'researcher' if user_params[:researcher] == 'on'
    nil
  end
end