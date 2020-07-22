class CreateUsersBaseController < ApplicationController

  def create_system_user
    # authorize! :sys_admin_links, User
    # @user.errors.add(:base, 'No sufficient permissions to create user type') unless current_user.system_administrator
    @model_school = School.find(1)
    @user = User.new(system_user_params)
    @user.errors.add(:base, 'Role is required!') if no_role_defined?
    @user.researcher = true if params[:user][:researcher] == 'on'
    @user.system_administrator = true if params[:user][:system_administrator] == 'on'
    @user = set_temporary_login_details(@user)
    @user.errors.add(:email, "Can't be blank") if system_user_params[:email].blank?

    if @user.errors.empty?
      if @user.save
        UserMailer.welcome_system_user(@user, get_server_config).deliver_now
        yield @user if block_given?
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def create_staff_user
    Rails.logger.debug("*** PARAMS #{params.inspect}")
    @user = User.new(staff_user_params)

    @user.school_id = current_school_id
    @user = set_temporary_login_details(@user)
    @school = get_current_school

    if @school.has_flag?(School::USERNAME_FROM_EMAIL) && @user.email.blank?
      @user.errors.add(:email, "email is required")
      # to do - find out why these @user.errors are not displaying in tests
      # @user_errors added to force an error message for tests
      @user_errors = ['There are Errors']
      render js: 'users/new_staff'
    elsif @user.errors.empty? && @user.save
      yield @user if block_given?
      UserMailer.welcome_user(@user, @school, get_server_config).deliver_now # deliver after save
      render js: "window.location.reload(true);"
    else
      # to do - find out why these @user.errors are not displaying in tests
      # @user_errors added to force an error message for tests
      @user_errors = ['There are Errors']
      flash[:alert] = "ERROR: #{@user.errors.full_messages}"
    end
  end

  # TODO: Come back and address why page isn't auto-refreshing
  def create_student_user
    @school = get_current_school
    @student = Student.new(student_params)
    @student.school_id = @school.id
    @student = set_temporary_login_details(@student)
    @parent = Parent.new(parent_params)
    err_msgs = []

    if @student.errors.empty?
      if @student.save
        yield @student if block_given?
        begin
          UserMailer.welcome_user(@student, @school, get_server_config).deliver_now
        rescue => e
          Rails.logger.error("Error: Student Email missing ServerConfigs record with support_email address")
          raise InvalidConfiguration, "Missing ServerConfigs record with support_email address"
        end
        # use parent if created already in student create
        # @parent = @student.parents.first
        Rails.logger.debug("*** @parent.assign_attributes(#{parent_params.inspect})")
        # puts("*** assign_attributes @parent.errors: #{@parent.errors.inspect}")
        Rails.logger.debug("*** assign_attributes @parent.errors.count: #{@parent.errors.count}")
        @parent.school_id = @school.id
        @parent.child_id = @student.id
        @parent = set_temporary_login_details(@parent)
        @parent.save
        begin
          UserMailer.welcome_user(@parent, @school, get_server_config).deliver_now
        rescue => e
          raise InvalidConfiguration, "Missing ServerConfigs record with support_email address"
        end

        err_msgs << @student.errors.full_messages if @student.errors.any?
        err_msgs << @parent.errors.full_messages if @parent.errors.any?
      else
        err_msgs << @student.errors.full_messages if @student.errors.any?
      end
    end

    flash[:alert] = err_msgs.join(', ') if err_msgs.any?
    # render js: 'create_users/create_student'
    render js: "window.location.reload(true);"
  end

  private

  def system_user_params
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
            :researcher,

        )
  end

  def staff_user_params
    params
        .require('user')
        .permit(
            :duty_par,
            :permission_par,
            :xid,
            :first_name,
            :last_name,
            :email,
            :street_address,
            :city,
            :state,
            :zip_code,
            :school_administrator,
            :counselor,
            :teacher,
            :password,
            :password_confirmation,
            :active,
            :school_id
        )
  end

  def student_params
    begin
      params
          .require(:student)
          .permit(
              :first_name,
              :last_name,
              :email,
              :grade_level,
              :street_address,
              :city,
              :state,
              :zip_code,
              :race,
              :gender,
              :special_ed,
              :password,
              :temporary_password,
              :xid,
              :filter,
              :active
          )
    rescue Exception => e
      ActionController::Parameters.new
    end
  end

  def parent_params
    begin
      params
          .require(:parent)
          .permit(
              :first_name,
              :last_name,
              :email,
              :password,
              :temporary_password,
              :subscription_status,
              :active
          )
    rescue
      ActionController::Parameters.new
    end
  end

  def set_temporary_login_details(user)
    user.set_unique_username
    user.set_temporary_password
    user
  end

  def no_role_defined?
    !params[:user][:system_administrator] == 'on' || !params[:user][:researcher] == 'on'
  end
end
