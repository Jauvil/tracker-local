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

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.infer_spec_type_from_file_location!

  config.include Devise::TestHelpers, :type => :controller
  config.include Features, :type => :feature
  config.include ApplicationHelper
  config.include Paperclip::Shoulda::Matchers



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
