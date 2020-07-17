module SsoSessions

 def create
    user = User.find_by_username(params[:user][:username])    
    body = { email: user.email, password: params[:user][:password]}
    response = HTTParty.post('http://localhost:3000/users/sign_in', body: body).parsed_response
    session[:jwt_token] = response['token']
    user = User.find_by_email(params[:user][:username] + "@21pstem.org")
    if user && response['token']
      sign_in user
      respond_with user, location: after_sign_in_path_for(user)
      return
    end
    redirect_to new_user_session_path, alert: "Invalid Credentials"
  end

  def destroy
    jwt_token = session[:jwt_token]
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    if signed_out
      set_flash_message! :notice, :signed_out
      response = HTTParty.delete('http://localhost:3000/users/sign_out', headers: sso_headers(jwt_token)).parsed_response
      session[:jwt_token] = response['token'] 
    end
    respond_to_on_destroy
  end

  private

  def sso_headers(token)
    { 'Authorization' => token }
  end

end