module SsoRegistrations

  def create
    super { |user| perform_sso_signup if SSO_ENABLED && user.persisted? }
  end

  # This method performs the sign up action on the SSO application
  def perform_sso_signup
    body = {user: sign_up_params}
    response = HTTParty.post('http://localhost:3000/users', body: body).parsed_response
    session[:jwt_token] = response['token']
  end
end
