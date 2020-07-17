module SsoRegistrations

  def create
    # This code will need to be integrated in clients to use SSO
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      # This is the only difference between the default Devise create and our extended create
      perform_sso_signup if SSO_ENABLED

      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # This method performs the sign up action on the SSO application
  def perform_sso_signup
    body = {user: sign_up_params}
    response = HTTParty.post('http://localhost:3000/users', body: body).parsed_response
    session[:jwt_token] = response['token']
  end
end
