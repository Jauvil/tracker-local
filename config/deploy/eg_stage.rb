set :stage, :eg_stage
server 'eg_stage.parloproject.org', roles: %w{web app db}
set :rvm_ruby_version, '2.2.9'
set :deploy_to, '/web/parlo-tracker/eg_stage'
set :rails_env, 'eg_stage'
set :bundle_dir, "~/.rvm/bin/gems/ruby-2.2.9-p480"
