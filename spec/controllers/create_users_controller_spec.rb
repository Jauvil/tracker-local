require 'rails_helper'
include Sso::Application

describe CreateUsersController do
  before(:each) do
    School.create(
        name: 'Model School',
        acronym: 'MOD',
        marking_periods: '2',
        city: 'Cairo',
        flags: 'use_family_name,user_by_first,grade_in_subject_name'
    )
    ServerConfig.create({"district_id"=>"", "district_name"=>"", "support_email"=>"jauvil@21pstem.org", "support_team"=>"Tracker Support Team", "school_support_team"=>"School IT Support Team", "server_url"=>"", "server_name"=>"Tracker System", "web_server_name"=>"PARLO Tracker Web Server", "allow_subject_mgr"=>false})
    @system_administrator = create :system_administrator
    token = JWT.encode({email: @system_administrator.email, expires_at: Time.now + 20.minutes}, JWT_PASSWORD)
    session[:jwt_token] = token
    sign_in @system_administrator
  end

  describe "POST create_system_user" do
    describe 'is an authorized user' do
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
        post :create_system_user, xhr: true, params: {user: system_user_params}
        expect(response.status).to eql(200)
        expect(User.find_by_email('new@system_user.com')).to_not be_nil
      end

      it 'has invalid params' do
        system_user_params = {
            first_name: 'Some',
            last_name: 'Guy',
            email: 'new2@system_user.com',
            street_address: '123 Anywhere Ln',
            city: 'Imaginaryville',
            state: 'CA',
            zip_code: '45042'
        }
        post :create_system_user, xhr: true, params: {user: system_user_params}
        expect(response.status).to eql(422)
      end
    end
    describe 'is an unauthorized user' do

    end
  end
end