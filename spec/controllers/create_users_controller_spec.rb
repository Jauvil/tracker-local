require 'rails_helper'
include Sso::Application

describe CreateUsersController do
  before(:all) do
    School.create(
        name: 'Model School',
        acronym: 'MOD',
        marking_periods: '2',
        city: 'Cairo',
        flags: 'use_family_name,user_by_first,grade_in_subject_name'
    )
    @school = FactoryBot.create(:school, name: "Example School #{rand(10000)}", acronym: "EXSCH#{rand(10000)}")
    ServerConfig.create({"district_id"=>"", "district_name"=>"", "support_email"=>"jauvil@21pstem.org", "support_team"=>"Tracker Support Team", "school_support_team"=>"School IT Support Team", "server_url"=>"", "server_name"=>"Tracker System", "web_server_name"=>"PARLO Tracker Web Server", "allow_subject_mgr"=>false})
    @system_administrator = User.where(system_administrator: true).first
    @system_administrator = FactoryBot.create(:system_administrator) if @system_administrator.nil?
  end

  before(:each) do
    token = JWT.encode({email: @system_administrator.email, expires_at: Time.now + 20.minutes}, Rails.secrets.json_api_key)
    session[:jwt_token] = token
    session[:school_context] = @school.id
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
        expect(User.find_by_email('new2@system_user.com')).to be_nil
      end
    end
  end

  describe "POST create_staff_user" do
    describe 'is an authorized user' do
      it "has valid params" do
        staff_user_params = {
            first_name: 'Staff',
            last_name: 'User',
            email: 'new@staff_user.com',
            street_address: '123 Anywhere Ln',
            city: 'Imaginaryville',
            state: 'CA',
            zip_code: '45042',
            school_administrator: 'on',
            counselor: 'on'
        }
        post :create_staff_user, xhr: true, params: {user: staff_user_params}
        expect(response.status).to eql(200)
        expect(User.find_by_email('new@staff_user.com')).to_not be_nil
      end

      it 'has invalid params' do
        staff_user_params = {
            first_name: 'Staff',
            last_name: 'User',
            email: 'new2@staff_user.com',
            street_address: '123 Anywhere Ln',
            city: 'Imaginaryville',
            state: 'CA',
            zip_code: '45042'
        }
        post :create_staff_user, xhr: true, params: {user: staff_user_params}
        expect(response.status).to eql(200)
        expect(User.find_by_email('new2@staff_user.com')).to be_nil
      end
    end
  end

  describe "POST create_student_user" do
    describe 'is an authorized user' do
      it "has valid params" do
        student_user_params = {
            first_name: 'Student',
            last_name: 'User',
            email: 'new@student_user.com',
            street_address: '123 Anywhere Ln',
            city: 'Imaginaryville',
            state: 'CA',
            zip_code: '45042',
            student: 'on',
            grade_level: 10
        }
        post :create_student_user, xhr: true, params: {student: student_user_params}
        expect(response.status).to eql(200)
        expect(User.find_by_email('new@student_user.com')).to_not be_nil
      end

      it 'has invalid params' do
        student_user_params = {
            first_name: 'Staff',
            last_name: 'User',
            email: 'new2@student_user.com',
            street_address: '123 Anywhere Ln',
            city: 'Imaginaryville',
            state: 'CA',
            zip_code: '45042'
        }
        post :create_student_user, xhr: true, params: {student: student_user_params}
        expect(response.status).to eql(200)
        expect(User.find_by_email('new2@student_user.com')).to be_nil
      end
    end
  end
end
