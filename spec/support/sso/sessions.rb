module Sso
  module Sessions
    include Client

    def create
      if SSO_ENABLED
        user = User.find_by_username(params[:user][:username])
        user = User.find_by_email(params[:user][:username]) if user.nil?
        super if user.nil?
        body = {email: user.email, password: params[:user][:password]}.to_json
        response = perform_sso_post('/users/sign_in', body)
        debugger
        session[:jwt_token] = response['token']
        if user && response['token']
          sign_in user
          respond_with user, location: after_sign_in_path_for(user)
          return
        end
        redirect_to new_user_session_path, alert: "Invalid Credentials"
      else
        super
      end
    end

    def destroy
      if SSO_ENABLED
        jwt_token = session[:jwt_token]
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        unless user_signed_in?
          set_flash_message! :notice, :signed_out
          puts sso_headers(jwt_token).to_s.green
          response = HTTParty.delete(Client::BASE_URL + '/users/sign_out', headers: sso_headers(jwt_token)).parsed_response
          session[:jwt_token] = nil unless response['success']

          session[:jwt_token] = response['token']

          reset_session
        end

        respond_to_on_destroy
      else
        super
      end
    end

    # This prevents Devise from checking for warden sessions before running the destroy controller action
    def verify_signed_out_user; end
  end
end
