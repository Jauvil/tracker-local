class SchoolStaff::AdministratorsController < ApplicationController
  before_action :authorize_user
  before_action :set_school, only: %i[users_with_missing_emails]
  before_action :set_users_with_missing_emails, only: %i[users_with_missing_emails]
  before_action :set_user, except: %i[users_with_missing_emails update_user_email]

  def users_with_missing_emails; end

  def edit_user_email; end

  def update_user_email
    user_id = user_params.delete(:id)
    @user = User.find(user_id)
    begin
      if UpdateUserEmail.perform(@user, user_params)
        redirect_to users_with_missing_emails_school_staff_administrators_path, notice: 'Successfully updated user email'
      else
        redirect_to edit_user_email_school_staff_administrator_path(@user), alert: 'Error updating user email'
      end
    rescue UpdateUserEmail::EmailsNotMatchingError, UpdateUserEmail::InvalidEmailError => e
      redirect_to edit_user_email_school_staff_administrator_path(@user), alert: e.message
    end
  end

  private

  def user_params
    params.require(:user).permit(:id, :email, :email_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def set_school
    @school = School.find(current_user.school_id)
  end

  def set_users_with_missing_emails
    if @school.is_a?(School)
      @users_with_missing_emails = @school.users.where('email = ? OR email IS NULL', '')
    else
      @users_with_missing_emails = []
    end
  end

  def authorize_user
    redirect_to root_path, alert: "You need to login to view this page" unless current_user.present? && current_user.school_administrator
  end
end
