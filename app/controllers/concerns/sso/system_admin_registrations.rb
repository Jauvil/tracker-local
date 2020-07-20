module Sso::SystemAdminRegistrations
  include TokenParser

  def create_system_user
    super do |user, password|
      # payload = {email: user.email, password: password}
      #TODO: encrypt params in token
      body = {user:
                  {email: user.email, password: password, password_confirmation: password}
      }
      # token = encode_token(payload)
      response = HTTParty.post('http://localhost:3000/users', body: body).parsed_response
      Rails.logger.debug("create system_user response - #{response.inspect}")
    end
  end
end