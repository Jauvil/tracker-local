module Sso::Registrations
  include Sso::Constants

  def create
    super { |user| perform_sso_signup if secrets['sso_enabled'] && user.persisted? }
  end

  # This method performs the sign up action on the SSO application
  def perform_sso_signup
    body = {user: sign_up_params}
    response = HTTParty.post(secrets['sso_url'] + '/users', body: body).parsed_response
    session[:jwt_token] = response['token']
  end
end
