  source 'http://rubygems.org'

  gem 'rails', '~> 4.2.10'
  # gem 'railties',  '~> 4.1.11'
  # gem 'passenger', '~> 3.0.21'       # Production web server.

  # Use unicorn as the app server
	# gem 'unicorn'

  gem 'whenever','~> 0.11', require: false
  gem 'rake', '< 11.0' # 10.5.0

  gem 'sass-rails', '~> 5.0'
  #   # See https://github.com/rails/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.1.0' # was 4.2.2
  # LESS compilation also out of asset pipeline to avoid missing vendor stylesheets
  gem 'less-rails'


# SSL implementation
gem 'rack-ssl', require: 'rack/ssl'

# Database!
gem 'mysql2', group: :production
gem 'sqlite3', '~> 1.3.0', group: [:development, :test]

# gem 'cancan'          # Authorization : See /app/models/ability.rb
gem 'cancancan', '~> 3.0.1'

gem 'acts_as_list'    # Drag and drop reordering, 'position' column.

gem 'paperclip'       # Upload / retrieve files via HTML.
gem "prawnto_2", '~> 0.3.0', :require => "prawnto"
gem 'prawn', '~> 2.2.2'           # Serve dynamically generated PDF's
gem 'axlsx_rails'
gem 'delayed_job_active_record', "~> 4.0.0"
gem "daemons", "~> 1.1.9" # needed to run delayed_job in production as daemon process.
gem 'faker', '~> 1.0.1'    # Generate fake strings, names etc for populating random data.
gem 'text'

# Application Monitoring / performance
gem 'newrelic_rpm'
#gem 'rack-mini-profiler'

# Miscellaneous
gem 'haml'            # Markup language to render HTML. Alternative to erb.
gem 'rabl'            # DSL for rendering JSON responses.
gem 'jquery-rails'
gem 'gretel', '~> 3.0.9'    # breadcrumbs ( last release for this gem )

#need this until we upgrade passenger gem. See: http://stackoverflow.com/questions/15076887/failed-to-build-gem-native-extension-ruby-2-0-upgrade-fastthread

gem 'fastthread', '~> 1.0.7', git: 'git://github.com/zoltankiss/fastthread.git'

gem 'nokogiri', '~> 1.6.3.1'
gem 'rack-cache', '~> 1.6.1'
gem 'devise' , '~> 4.6.2'   # Authentication

# respond_with and the class-level respond_to methods have been extracted to the responders gem
gem 'responders', '~> 2.0'

group :test do
  gem 'rspec-rails', '~> 3.8.2'
  # gem 'webdrivers'
  # gem 'chromedriver-helper'
  gem 'geckodriver-helper'
  gem 'capybara', '~> 2.18.0'
  gem 'selenium-webdriver', '~> 3.8.0'
  gem 'factory_bot_rails', require: false
  gem 'guard-rspec'
  gem 'simplecov', require: false
  gem 'test-unit'
end

group :development, :test do
  # gem "ruby-prof", "~> 0.13.0"
  # # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug'

end

group :development do
  gem 'letter_opener', '~> 1.1.2'
  gem 'launchy', '~> 2.3.0'
  gem 'addressable', '~> 2.3.5'
  gem 'capistrano', '3.0.1'
  gem 'capistrano-rails', '1.1.0'
  gem 'capistrano-rvm', '0.0.3'
  gem 'sshkit', '1.3.0'
  # gem to help manage version upgrades (recommended by ombu labs)
  # gem 'ten_years_rails', '~> 0.2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

end

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc
