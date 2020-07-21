module Sso::SystemAdminRegistrations
  include TokenParser

  def create_system_user
    super do |user|
      body = {
        user:{
          email: user.email, 
          password: user.temporary_password, 
          password_confirmation: user.temporary_password
        }
      }
      # token = encode_token(payload)
      response = HTTParty.post('http://localhost:3000/users', body: body).parsed_response
      Rails.logger.debug("create system_user response - #{response.inspect}")
    end
  end
end