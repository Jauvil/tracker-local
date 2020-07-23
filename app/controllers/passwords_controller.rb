class PasswordsController < ApplicationController
  include Sso::Client

  before_action :set_user

  def update
    if Users::UpdatePasswordService.perform(@user, user_params, get_current_school, get_server_config)
      Rails.logger.debug("Update password was successful".green)
      # TODO:  Get clarification on what to do when client PW update succeeds and SSO fails
      status = update_sso_password(@user.email)
      sign_in @user unless user_signed_in?
      redirect_to(root_path, :notice => 'Password was successfully updated.')
    else
      Rails.logger.debug("Update password failed".red)
      redirect_to(change_password_user_path, alert: 'Problem with changing password')
    end
  end

  private

  def set_user
    @current_role = set_current_role
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def update_sso_password(email)
    begin
      body = {
          user: {
              email: email,
              password: params[:user][:password], password_confirmation: params[:user][:password]
          }
      }.to_json
      token = JWT.encode({email: email}, JWT_PASSWORD)
      response = perform_sso_put('/users/passwords', body, token)
      Rails.logger.debug("Response - #{response.inspect}".yellow)
      response['success']
    rescue SocketError => e
      # This rescue block will catch only a failed network request. I remember this being a specific edge case we need
      # to account for. Anything else will blow up.
      # TODO: Possible solution:
      # TODO: Add to a database table (ie. pw_reset_network_failures) -- Would need encryption
      # TODO: Possibly run a cron job that checks if internet is accessible and synch decrypted password with SSO
    end
  end
end
