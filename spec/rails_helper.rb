#Simplecov lines MUST be first in this file for code coverage to work
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/lib/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
end if ENV["COVERAGE"]

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# ActiveRecord::Migration.maintain_test_schema! # does not work - https://relishapp.com/rspec/rspec-rails/docs/upgrade
require 'capybara/rspec'
require 'paperclip/matchers'
require 'coffee_script'
require 'factory_bot_rails'
require 'model_helper'
require 'spec_helper'
require "test/unit/assertions"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

include Test::Unit::Assertions

Capybara.configure do |config|
  # prevent test failing fron missing 'images/login_bg.png'
  config.raise_server_errors = false
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.infer_spec_type_from_file_location!

  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include Features, :type => :feature
  config.include ApplicationHelper
  config.include Paperclip::Shoulda::Matchers
  config.include Capybara::DSL



  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  #Allows us to call factories without prefacing with FactoryBot
  config.include FactoryBot::Syntax::Methods

  # temporarily allow should syntax without deprecation warnings
  # To Do - replace all should tests with expect tests (many hundreds)
  # see: https://relishapp.com/rspec/rspec-expectations/docs/syntax-configuration
  config.expect_with(:rspec) { |c| c.syntax = :should, :expect}
end

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# # Set the test log to just show warnings and above.
# # replace with code in config/environments/test.rb
# Rails.logger.level = 2


# SSO LOGIN HELPER METHODS

def create_token_and_sign_in(user)
  school = FactoryBot.create(:school)
  token = JWT.encode({email: user.email, expires_at: Time.now + 20.minutes}, Rails.secrets.json_api_key)
  session[:jwt_token] = token
  session[:school_context] = school.id
  sign_in user
end

def create_token_and_sign_in_system_administrator
  user = User.where(system_administrator: true).first || FactoryBot.create(:system_administrator)
  create_token_and_sign_in(user)
end

def create_token_and_sign_in_student
  user = User.where(student: true).first || FactoryBot.create(:student)
  create_token_and_sign_in(user)
end

def create_token_and_sign_in_teacher
  user = User.where(teacher: true).first || FactoryBot.create(:teacher)
  create_token_and_sign_in(user)
end

def create_token_and_sign_in_school_administrator
  user = User.where(school_administrator: true).first || FactoryBot.create(:school_administrator)
  create_token_and_sign_in(user)
end

def model_school_attributes
  {
      name: 'Model School',
      acronym: 'MOD',
      marking_periods: '2',
      city: 'Cairo',
      flags: 'use_family_name,user_by_first,grade_in_subject_name'
  }
end

def server_config_attributes
  {
      district_id: "",
      district_name: "",
      support_email: "jauvil@21pstem.org",
      support_team: "Tracker Support Team",
      school_support_team: "School IT Support Team",
      server_url: "", server_name: "Tracker System",
      web_server_name: "PARLO Tracker Web Server",
      allow_subject_mgr: false
  }
end

def base_user_attributes
  {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.unique.email,
      street_address: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state,
      zip_code: Faker::Address.zip
  }
end

def system_user_params(valid=true)
  attrs = base_user_attributes
  attrs['system_administrator'] = 'on' if valid
  attrs['researcher'] = 'on' if valid
  attrs
end

def staff_user_params(valid=true)
  attrs = base_user_attributes
  attrs['counselor'] = 'on' if valid
  attrs['school_administrator'] = 'on' if valid
  attrs
end

def student_user_params(valid=true)
  attrs = base_user_attributes
  attrs['student'] = 'on' if valid
  attrs['grade_level'] = '10' if valid
  attrs
end
