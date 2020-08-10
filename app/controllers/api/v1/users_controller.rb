class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: %i[update]

  def create
    user = Users::DecodePwTokenAndSave.perform(user_params)
    if user.errors.empty?
      render json: {success: true, user: user}
    else
      render json: {success: false, errors: user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: {success: true, user: @user}
    else
      render json: {success: false, errors: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :family_name, :given_name, :password_token, roles: [])
  end

  def set_user
    @user = User.find(params[:id])
  end
end
