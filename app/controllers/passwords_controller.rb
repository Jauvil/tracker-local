class PasswordsController < ApplicationController
  before_action :set_user

  def update
    if @user.update_attributes(user_params)
      Rails.logger.debug("*** change password.")
      unless @user.temporary_password == @user.password
        @user.temporary_password = nil 
        @user.save

      end
      UserMailer.changed_user_password(@user, @school, get_server_config).deliver_now 
      redirect_to(root_path, :notice => 'Password was successfully updated.')
    else
      redirect_to(change_password_user_path, alert: 'Problem with changing password')
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end