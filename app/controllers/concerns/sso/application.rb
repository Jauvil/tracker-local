module Sso::Application
  def sso_handle_intercomponent_request
    session[:jwt_token] = params[:jwt_token]
    sso_set_token_data
    if sso_verify_token
      if @current_user.nil?
        password = SecureRandom.urlsafe_base64(16)
        @current_user = User.create(email: @payload['email'], password: password, password_confirmation: password)
      end

      sign_in @current_user
    end
  end

  def is_intercomponent_request?
    return false if request.referer.nil?
    port_and_path = request.referer.split(':').last
    port = Integer(port_and_path.split('/').first)
    port != APP_PORT && params[:jwt_token].present?
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
      token_data = JWT.decode(session[:jwt_token], JWT_PASSWORD, true, algorithm: 'HS256')
    rescue JWT::DecodeError
      token_data = nil
    end

    @payload = token_data.nil? ? nil : token_data[0]
    @current_user = @payload.nil? ? nil : User.find_by_email(@payload['email'])
  end
end