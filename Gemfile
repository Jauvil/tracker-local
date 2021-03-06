  source 'http://rubygems.org'

  ruby "2.5.6"

  gem 'rails', '5.0.7.2'
  # gem 'railties',  '~> 4.1.11'
  # gem 'passenger', '~> 3.0.21'       # Production web server.

  # Use unicorn as the app server
	# gem 'unicorn'

  gem 'whenever', '~> 1.0.0', require: false
  gem 'rake', '~> 13.0.0'

  gem 'sass-rails', '~> 6.0.0'
  #   # See https://github.com/rails/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.2.2'
  # LESS compilation also out of asset pipeline to avoid missing vendor stylesheets
  gem 'less-rails'

gem 'rails-dom-testing', '~> 2.0.3'

# SSL implementation
gem 'rack-ssl', require: 'rack/ssl'

# Database!
gem 'mysql2', group: :production
gem 'sqlite3', '~> 1.3.6', group: [:development, :test]

# gem 'cancan'          # Authorization : See /app/models/ability.rb
gem 'cancancan', '~> 3.0.1'

gem 'acts_as_list'    # Drag and drop reordering, 'position' column.

gem 'paperclip'       # Upload / retrieve files via HTML.
gem 'prawn', '~> 2.2.2'           # Serve dynamically generated PDF's
gem "prawnto_2", '~> 0.3.0', :require => "prawnto"
gem 'prawn-table', '~> 0.2.2'
gem 'axlsx_rails'
gem 'delayed_job_active_record', '~> 4.1.4'
gem "daemons", '~> 1.3.1' # needed to run delayed_job in production as daemon process.
gem 'faker', '~> 2.5.0'   # Generate fake strings, names etc for populating random data.
gem 'text'
gem 'colorize'

# Application Monitoring / performance
gem 'newrelic_rpm'
gem 'rack-mini-profiler'
# For memory profiling
gem 'memory_profiler'
# For call-stack profiling flamegraphs
gem 'flamegraph'
gem 'stackprof'

# Miscellaneous
gem 'haml'            # Markup language to render HTML. Alternative to erb.
gem 'rabl'            # DSL for rendering JSON responses.
gem 'jquery-rails'
gem 'gretel', '~> 3.0.9'    # breadcrumbs ( last release for this gem )

#need this until we upgrade passenger gem. See: http://stackoverflow.com/questions/15076887/failed-to-build-gem-native-extension-ruby-2-0-upgrade-fastthread

gem 'fastthread', '~> 1.0.7', git: 'git://github.com/zoltankiss/fastthread.git'

gem 'nokogiri', '~> 1.10.4'
gem 'rack-cache', '~> 1.9.0'
gem 'devise', '~> 4.7.1'  # Authentication
gem 'jwt'
gem 'httparty'

# respond_with and the class-level respond_to methods have been extracted to the responders gem
gem 'responders', '~> 3.0.0'

group :test do
  gem 'rspec-rails', '~> 3.8.2'
  # gem 'webdrivers'
  # gem 'chromedriver-helper'
  gem 'geckodriver-helper'

  #Capybara not updated for the 5.0 upgrade- concern for test system stability. Update as needed.
  gem 'capybara', '~> 2.18.0'
  gem 'selenium-webdriver', '~> 3.142.5'
  gem 'factory_bot_rails', require: false
  gem 'guard-rspec'
  gem 'simplecov', require: false
  gem 'test-unit'
end

group :development, :test do
  # gem "ruby-prof", "~> 0.13.0"
  # # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

end

group :development do
  gem 'letter_opener', '~> 1.7.0'
  gem 'launchy', '~> 2.4.3'
  gem 'addressable', '~> 2.7.0'

  gem 'capistrano', '~> 3.11.2'
  gem 'capistrano-rails', "~> 1.4.0"
  gem 'capistrano-rvm', "~> 0.1.2"

  gem 'sshkit', '~> 1.20.0'
  # gem to help manage version upgrades (recommended by ombu labs)
  gem 'ten_years_rails', '~> 0.2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.7.0'

end

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '1.0.0',         group: :doc
