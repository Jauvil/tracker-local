module Sso::Application
  include Sso::Constants

  def sso_handle_intercomponent_request
    session[:jwt_token] = params[:jwt_token]
    sso_set_token_data
    if sso_verify_token
      # TODO: I don't think we want to create a user out of nowhere just because it doesn't exist. We're assuming
      # TODO: users will be synched but will need to write a graceful fail for the edge case of that not being so.


      if @current_user.nil?
        Rails.logger.error("Current user was nil when queried by email: #{@payload['email']}")
        # password = SecureRandom.urlsafe_base64(16)
        # @current_user = User.create(email: @payload['email'], password: password, password_confirmation: password)
      end

      sign_in @current_user
    end
  end

  def is_intercomponent_request?
    # TODO: This is not working as planned. We can check for a JWT Token and it works but I'd like to find a
    # TODO: more concrete solution.

    Rails.logger.error("Request referer was nil") if request.referer.nil?
    # return false if request.referer.nil?
    # port_and_path = request.referer.split(':').last
    # port = Integer(port_and_path.split('/').first)
    params[:jwt_token].present?
  end

  def sso_verify_token
    return true if sso_is_valid_token?

    unless @payload.nil?
      user = User.find_by_email @payload['email']
      sign_out user if current_user.present? && user == current_user
    end

    false
  end

  def sso_is_valid_token?
    return false if session[:jwt_token].nil?

    return false if @payload['invalid'].present?

    @payload['expires_at'] > Time.now
  end

  def sso_set_token_data
    begin
      token_data = JWT.decode(session[:jwt_token], secrets['json_api_key'], true, algorithm: 'HS256')
    rescue JWT::DecodeError
      token_data = nil
    end

    Rails.logger.debug("TOKEN DATA - #{token_data}".green)
    @payload = token_data.nil? ? nil : token_data[0]
    @current_user = @payload.nil? ? nil : User.find_by_email(@payload['email'])
  end
end
