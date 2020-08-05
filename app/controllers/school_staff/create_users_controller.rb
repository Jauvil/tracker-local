class SchoolStaff::CreateUsersController < CreateUsersBaseController
  include Sso::SystemAdminRegistrations
  before_action :verify_staff_can_create_user

  private

  def verify_staff_can_create_user
    redirect_to root_path, alert: "You don't have permission to perform this action." unless is_staff?
    if params['user'].present? && (params['user']['teacher'] == 'on' || params['user']['counselor'] == 'on') && !current_user.school_administrator
      redirect_to root_path, alert: "You don't have permission to perform this action."
    end
  end

  def is_staff?
    current_user.school_administrator || current_user.counselor || current_user.teacher
  end
end
