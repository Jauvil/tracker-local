require 'rails_helper'
require 'faker'
include Sso::Application

describe SysAdmin::CreateUsersController do
  before(:all) do
    School.create(model_school_attributes)
    ServerConfig.create({"district_id" => "", "district_name" => "", "support_email" => "jauvil@21pstem.org", "support_team" => "Tracker Support Team", "school_support_team" => "School IT Support Team", "server_url" => "", "server_name" => "Tracker System", "web_server_name" => "PARLO Tracker Web Server", "allow_subject_mgr" => false})
    @system_administrator = User.where(system_administrator: true).first
    @system_administrator = FactoryBot.create(:system_administrator) if @system_administrator.nil?
  end

  describe "POST system_administrator" do
    describe 'is an authorized user' do
      it "has valid params" do
        create_token_and_sign_in_system_administrator
        request_params = system_user_params
        user_email = request_params[:email]
        post :system_administrator, xhr: true, params: { user: request_params }
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to_not be_nil
      end

      it 'has invalid params' do
        create_token_and_sign_in_system_administrator
        request_params = system_user_params(false)
        user_email = request_params[:email]
        post :system_administrator, xhr: true, params: { user: request_params }
        expect(response.status).to eql(422)
        expect(User.find_by_email(user_email)).to be_nil
      end
    end

    describe 'is an unauthorized user' do
      it 'has valid params' do
        create_token_and_sign_in_student
        request_params = system_user_params
        user_email = request_params[:email]
        post :system_administrator, xhr: true, params: {user: request_params}
        expect(flash[:alert]).to eql("You don't have permission to perform this action.")
        expect(User.find_by_email(user_email)).to be_nil
      end
    end
  end

  describe "POST staff" do
    describe 'is an authorized user' do
      it "has valid params" do
        create_token_and_sign_in_system_administrator
        request_params = staff_user_params
        user_email = request_params[:email]
        post :staff, xhr: true, params: { user: request_params }
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to_not be_nil
      end

      it 'has invalid params' do
        create_token_and_sign_in_system_administrator
        request_params = staff_user_params(false)
        user_email = request_params[:email]
        post :staff, xhr: true, params: { user: request_params }
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to be_nil
      end
    end

    describe 'is an unauthorized user' do
      it 'has valid params' do
        create_token_and_sign_in_student
        request_params = staff_user_params
        user_email = request_params[:email]
        post :staff, xhr: true, params: { user: request_params }
        expect(flash[:alert]).to eql("You don't have permission to perform this action.")
        expect(User.find_by_email(user_email)).to be_nil
      end
    end
  end

  describe "POST student" do
    describe 'is an authorized user' do
      it "has valid params" do
        create_token_and_sign_in_system_administrator
        request_params = student_user_params
        user_email = request_params[:email]
        post :student, xhr: true, params: { student: request_params }
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to_not be_nil
      end

      it 'has invalid params' do
        create_token_and_sign_in_system_administrator
        request_params = student_user_params(false)
        user_email = request_params[:email]
        post :student, xhr: true, params: {student: request_params}
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to be_nil
      end
    end

    describe 'is an unauthorized user' do
      it 'has valid params' do
        create_token_and_sign_in_student
        request_params = student_user_params
        user_email = request_params[:email]
        post :student, xhr: true, params: { user: request_params }
        expect(flash[:alert]).to eql("You don't have permission to perform this action.")
        expect(User.find_by_email(user_email)).to be_nil
      end
    end
  end
end
