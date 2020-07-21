class CreateUsersController < ApplicationController

  def create
    
  end


  def create_system_user
    authorize! :sys_admin_links, User
    @model_school = School.find(1)
    @user = User.new(system_user_params)
    @user.errors.add(:base, 'Role is required!') if defined_role.nil?
    defined_role == 'researcher' ?
    @user.researcher = true : @user.system_administrator = true
    @user.set_unique_username
    @user.set_temporary_password
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
    @user.set_unique_username
    @user.set_temporary_password

    @school = get_current_school

    # if user_params['school_administrator']
    #   set_role(@user, 'school_administrator', user_params['school_administrator'])
    #   Rails.logger.debug("*** user_params['school_administrator'] #{user_params['school_administrator'].inspect}")
    # end

    # if user_params['teacher']
    #   set_role(@user, 'teacher', user_params['teacher'])
    #   Rails.logger.debug("*** user_params['teacher'] #{user_params['teacher'].inspect}")
    # end

    # if user_params['counselor']
    #   set_role(@user, 'counselor', user_params['counselor'])
    #   Rails.logger.debug("*** user_params['counselor'] #{user_params['counselor'].inspect}")
    # end

    # ToDo move this into case statement
    # @user.errors.add(:base, "not allowed to update this type of user: #{@user.role_symbols.inspect}") if !can?(:update, @user)

    if @school.has_flag?(School::USERNAME_FROM_EMAIL) && @user.email.blank?
      @user.errors.add(:email, "email is required")
      # to do - find out why these @user.errors are not displaying in tests
      # @user_errors added to force an error message for tetst
      @user_errors = ['There are Errors']
      render js: 'users/new_staff'
    elsif @user.errors.count == 0 && @user.save
      yield @user if block_given?
      UserMailer.welcome_user(@user, @school, get_server_config).deliver_now # deliver after save
      render js: "window.location.reload(true);"
    else
      # to do - find out why these @user.errors are not displaying in tests
      # @user_errors added to force an error message for tetst
      @user_errors = ['There are Errors']
      flash[:alert] = "ERROR: #{@user.errors.full_messages}"
    end
  end  

  def create_student
    @school = get_current_school
    @student = Student.new
    @student.assign_attributes(student_params)
    # puts("*** initial errors: #{@student.errors.full_messages}")
    @student.school_id = @school.id
    @student.set_unique_username
    @student.set_temporary_password
    @student.valid?
    # puts("*** set errors: #{@student.errors.full_messages}")
    # ensure instance variable exists, even if errors
    # don't create parent until after successful student create
    @parent = Parent.new
      
    @student.save if @student.errors.empty?
      # puts("*** after no errors save, errors: #{@student.errors.full_messages}")
    if @student.errors.empty?
      # puts("*** no student errors after save")
      begin
        UserMailer.welcome_user(@student, @school, get_server_config).deliver_now
      rescue => e
        Rails.logger.error("Error: Student Email missing ServerConfigs record with support_email address")
        raise InvalidConfiguration, "Missing ServerConfigs record with support_email address"
      end
      # use parent if created already in student create
      @parent = @student.parents.first
      if @parent.blank?
        @parent = Parent.new
      end
      Rails.logger.debug("*** @parent.assign_attributes(#{parent_params.inspect})")
      @parent.assign_attributes(parent_params)
      # puts("*** assign_attributes @parent.errors: #{@parent.errors.inspect}")
      Rails.logger.debug("*** assign_attributes @parent.errors.count: #{@parent.errors.count}")
      @parent.school_id = @school.id
      @parent.set_unique_username
      @parent.set_temporary_password
      parent_status = @parent.save
      # puts("*** save @parent.errors: #{@parent.errors.inspect}")
      Rails.logger.debug("*** save @parent.errors.count: #{@parent.errors.count}")
      # puts("*** save parent_status: #{parent_status.inspect}")
      begin
        UserMailer.welcome_user(@parent, @school, get_server_config).deliver_now
      rescue => e
        Rails.logger.error("Error: Parent Email missing ServerConfigs record with support_email address")
        raise InvalidConfiguration, "Missing ServerConfigs record with support_email address"
      end
      err_msgs = []
      err_msgs << @student.errors.full_messages if @student.errors.count > 0
      err_msgs << @parent.errors.full_messages if @parent.errors.count > 0
    else
      err_msgs = []
      err_msgs << @student.errors.full_messages if @student.errors.count > 0
      # puts("*** unsuccessful before or after student save")
    end
    # puts("*** final errors: #{@student.errors.full_messages}")
    # puts("*** final errors count: #{@student.errors.count}")
    flash[:alert] = err_msgs.join(', ') if err_msgs.length > 0
    flash.each do |name, msg|
      Rails.logger.debug("*** flash message: #{msg}") if msg.is_a?(String)
    end
    render js: 'create_users/create_student'
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

  def defined_role
    return 'system_administrator' if system_user_params[:system_administrator] == 'on'
    return 'researcher' if system_user_params[:researcher] == 'on'
    nil
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

end