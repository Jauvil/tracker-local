module Sso
  module Sessions
    include Headers

    def create
      if SSO_ENABLED
        user = User.find_by_username(params[:user][:username])
        body = {email: user.email, password: params[:user][:password]}
        response = HTTParty.post('http://localhost:3000/users/sign_in', body: body).parsed_response
        session[:jwt_token] = response['token']
        if user && response['token']
          sign_in user
          respond_with user, location: after_sign_in_path_for(user)
          return
        else
          #TODO: research why a user can be logged in after we call sign_out method.
          # Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        end
        debugger
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
          response = HTTParty.delete('http://localhost:3000/users/sign_out', headers: sso_headers(jwt_token)).parsed_response
          session[:jwt_token] = nil unless response['success']

          session[:jwt_token] = response['token']

          reset_session
        end
        debugger
        respond_to_on_destroy
      else
        super
      end
    end

    def verify_signed_out_user; end
  end
end
