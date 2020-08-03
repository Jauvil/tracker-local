require 'rails_helper'

describe SessionsController do
  before(:all) do
    @system_administrator = create(:system_administrator, username: "RandomUser#{rand(100000)}", email: "test_admin#{rand(100000)}@abc#{rand(999)}.com", password: 'Simple123!', password_confirmation: 'Simple123!')
  end

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST create" do
    it "has correct login info" do
      SessionsController.any_instance.stub(:get_sso_response) do
        token = JWT.encode({ email: @system_administrator.email, expires_at: Time.now + 20.minutes }, Rails.application.secrets.json_api_key)
        {'success' => true, 'token' => token}
      end
      expect(session[:jwt_token]).to be_nil
      post :create, params: { user: { username: @system_administrator.email, password: 'Simple123!' } }
      expect(session[:jwt_token]).to_not be_nil
    end
  end

  describe "DELETE destroy" do
    it 'should log user out' do
      sign_in @system_administrator
      pre_sign_in_token = JWT.encode({ email: @system_administrator.email, expires_at: Time.now + 20.minutes }, Rails.application.secrets.json_api_key)
      session[:jwt_token] = pre_sign_in_token
      SessionsController.any_instance.stub(:get_sso_response) do
        token = JWT.encode({ email: @system_administrator.email, expires_at: nil, invalid: true }, Rails.application.secrets.json_api_key)
        {'success' => true, 'token' => token}
      end
      delete :destroy
      expect(response.code).to eql('302')
    end
  end
end
