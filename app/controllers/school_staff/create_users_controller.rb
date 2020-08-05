class SchoolStaff::CreateUsersController < CreateUsersBaseController
  include Sso::SystemAdminRegistrations
  before_action :verify_staff_can_create_user

  private

  def verify_staff_can_create_user
    error_message = "You don't have permission to perform this action."
    redirect_to root_path, status: :unauthorized, alert: error_message unless is_staff?
    if params['user'].present? && is_creating_staff_user?
      redirect_to root_path, status: :unauthorized, alert: error_message unless current_user.school_administrator
    end
  end

  def is_staff?
    current_user.school_administrator || current_user.counselor || current_user.teacher
  end

  def is_creating_staff_user?
    params['user']['teacher'] == 'on' ||
        params['user']['counselor'] == 'on' ||
        params['user']['school_administrator'] == 'on'
  end
end
