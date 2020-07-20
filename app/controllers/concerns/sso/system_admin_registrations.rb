module Sso::SystemAdminRegistrations
  include TokenParser

  def create_system_user
    super do |user|
      # payload = {email: user.email, password: user.temporary_password}
      #TODO: encrypt params in token
      # What I did: removed second arg in block and updated the password field.
      # User is now created in SSO and can verify temporary_password and log in.
      # Things to work on next: 
        # 1. when user password is reset or updated, it should also update SSO!
        # 2. permissions in SSO!
        # 3. add this logic to all controllers that create users!
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