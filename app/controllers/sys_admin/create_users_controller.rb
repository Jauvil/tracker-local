class SysAdmin::CreateUsersController < CreateUsersBaseController
  include Sso::SystemAdminRegistrations
  before_action :verify_system_admin

  private

  def verify_system_admin
    redirect_to root_path, alert: "You don't have permission to perform this action." unless current_user.system_administrator
  end
end