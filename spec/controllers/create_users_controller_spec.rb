require 'rails_helper'
include Sso::Application

describe CreateUsersController do
  before(:each) do
    @system_administrator = create :system_administrator
    token = JWT.encode({email: @system_administrator.email, expires_at: Time.now + 20.minutes}, JWT_PASSWORD)
    session[:jwt_token] = token
    sign_in @system_administrator
  end

  describe "POST create_system_user" do
    it "has valid params" do
      system_user_params = {
          first_name: 'Some',
          last_name: 'Guy',
          email: 'new@system_user.com',
          street_address: '123 Anywhere Ln',
          city: 'Imaginaryville',
          state: 'CA',
          zip_code: '45042',
          system_administrator: 'on',
          researcher: 'on'
      }
      headers = { "Accept" => "text/javascript" }
      # page.driver.post '/create_users/create_system_user', params: {user: system_user_params}, headers: headers, xhr: true
      # expect(page.driver.status_code).to eql(302)
      post :create_system_user, xhr: true, params: {user: system_user_params}
      puts response.body.green
    end
  end
end