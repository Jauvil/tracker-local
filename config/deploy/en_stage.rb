set :stage, :en_stage
server 'en_stage.parloproject.org', roles: %w{web app db}
set :rvm_ruby_version, '2.2.9'
set :deploy_to, '/web/parlo-tracker/en_stage'
set :rails_env, 'en_stage'
set :bundle_dir, "~/.rvm/bin/gems/ruby-2.2.9-p480"
