  source 'http://rubygems.org'

  gem 'rails', '4.0.13'
  gem 'railties',  '4.0.13'
  gem 'passenger', '3.0.18'       # Production web server.
  gem 'whenever','~>0.9', require: false
  # gem 'rake', '10.1.0' # for Rails 3.2
  gem 'rake', '< 11.0' # for rails 4.0

  # # Gems used only for assets and not required
  # # in production environments by default.
  # group :assets do
  #   # gem 'sass-rails',   '~> 3.2.3' # for Rails 3.2
    gem 'sass-rails'
  #   # See https://github.com/sstephenson/execjs#readme for more supported runtimes
    gem 'therubyracer', :platforms => :ruby
  #   gem 'uglifier', '>= 1.0.3'
  # end

  # moved out of assets groups for use in views also

  # gem 'coffee-rails', '~> 3.2.1'

  gem 'coffee-rails'
  # LESS compilation also out of asset pipeline to avoid missing vendor stylesheets
  gem 'less-rails'


# SSL implementation
gem 'rack-ssl', require: 'rack/ssl'

# Database!
gem 'mysql2', group: :production
gem 'sqlite3', group: [:development, :test]

gem 'cancan'          # Authorization : See /app/models/ability.rb

gem 'acts_as_list'    # Drag and drop reordering, 'position' column.

gem 'paperclip'       # Upload / retrieve files via HTML.
# gem 'prawnto' # for Rails 3.2
gem 'prawn'           # Serve dynamically generated PDF's
gem 'axlsx_rails'
gem 'delayed_job_active_record', "~> 4.0.0"
gem "daemons", "~> 1.1.9" # needed to run delayed_job in production as daemon process.
gem 'faker', '1.0.1'    # Generate fake strings, names etc for populating random data.
gem 'text'

# Application Monitoring / performance
gem 'newrelic_rpm'
#gem 'rack-mini-profiler'

# Miscellaneous
gem 'haml'            # Markup language to render HTML. Alternative to erb.
gem 'rabl'            # DSL for rendering JSON responses.
gem 'jquery-rails'
gem 'zip-zip'         # provides compatibility for rubyzip pre 1.0 (for selenium-webdriver)
# todo - fix problems with 'i18n-js'
# gem 'i18n-js', '2.1.2'
# gem 'gretel', '~> 3.0.7'    # breadcrumbs for Rails 3.2
gem 'gretel', '3.0.9'    # breadcrumbs ( last release for this gem )

#gem 'letter_opener', group: :development # Opens emails in new window in development.

#need this until we upgrade passenger gem. See: http://stackoverflow.com/questions/15076887/failed-to-build-gem-native-extension-ruby-2-0-upgrade-fastthread

gem 'fastthread', '1.0.7', git: 'git://github.com/zoltankiss/fastthread.git'

# fixes for being old:
# gem 'bullet', '4.6.0', group: :development
gem 'nokogiri', '1.6.3.1'
gem 'rack-cache', '1.6.1'
gem 'devise', '3.0.0'   # Authentication


group :development, :test do
  gem 'rspec-rails', '2.14.0'
  gem 'rspec-mocks', '2.14.2'
  gem 'rspec-expectations', '2.14.0'
  gem 'rspec-core', '2.14.4'
  gem 'letter_opener', '1.1.2'
  gem 'launchy', '2.3.0'
  gem 'addressable', '2.3.5'
  gem 'sshkit', '1.3.0'
  gem 'capybara', '1.1.2'
  gem 'factory_girl_rails', require: false
  gem 'guard-rspec'
  gem 'simplecov'
  gem 'selenium-webdriver'
  gem "ruby-prof", "~> 0.13.0"
end

group :development do
  #gem 'bullet'
  gem 'capistrano', '3.0.1'
  gem 'capistrano-rails', '1.1.0'
  gem 'capistrano-rvm', '0.0.3'
end
