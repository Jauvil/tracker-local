require 'rails_helper'
include Sso::Application

describe SchoolStaff::CreateUsersController do
  before(:all) do
    School.create(model_school_attributes)
    ServerConfig.create(server_config_attributes)
  end

  describe "POST staff" do
    describe 'is a school administrator' do
      describe 'and creates a staff user' do
        it "has valid params" do
          create_token_and_sign_in_school_administrator
          request_params = staff_user_params
          user_email = request_params[:email]
          post :staff, xhr: true, params: {user: request_params}
          expect(response.status).to eql(200)
          expect(User.find_by_email(user_email)).to_not be_nil
        end
        it 'has invalid params' do
          create_token_and_sign_in_school_administrator
          request_params = staff_user_params(false)
          user_email = request_params[:email]
          post :staff, xhr: true, params: {user: request_params}
          expect(response.status).to eql(200)
          expect(User.find_by_email(user_email)).to be_nil
        end
      end
    end
    describe 'is a teacher or counselor' do
      describe 'and creates a staff user' do
        it "has valid params" do
          create_token_and_sign_in_teacher
          request_params = staff_user_params
          user_email = request_params[:email]
          post :staff, xhr: true, params: {user: request_params}
          expect(response.status).to eql(401)
          expect(flash[:alert]).to eql("You don't have permission to perform this action.")
          expect(User.find_by_email(user_email)).to be_nil
        end
      end
    end
  end

  describe "POST student" do
    describe 'is a school administrator' do
      it "has valid params" do
        create_token_and_sign_in_school_administrator
        request_params = student_user_params
        user_email = request_params[:email]
        post :student, xhr: true, params: {student: request_params}
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to_not be_nil
      end

      it 'has invalid params' do
        create_token_and_sign_in_school_administrator
        request_params = student_user_params(false)
        user_email = request_params[:email]
        post :student, xhr: true, params: { student: request_params }
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to be_nil
      end
    end
    describe 'is a teacher or counselor' do
      it "has valid params" do
        create_token_and_sign_in_teacher
        request_params = student_user_params
        user_email = request_params[:email]
        post :student, xhr: true, params: { student: request_params }
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to_not be_nil
      end

      it 'has invalid params' do
        create_token_and_sign_in_teacher
        request_params = student_user_params(false)
        user_email = request_params[:email]
        post :student, xhr: true, params: { student: request_params }
        expect(response.status).to eql(200)
        expect(User.find_by_email(user_email)).to be_nil
      end
    end
  end
end
