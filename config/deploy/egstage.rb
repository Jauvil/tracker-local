set :stage, :egstage
server 'egstage.parloproject.org', roles: %w{web app db}
set :rvm_ruby_version, '2.2.9'
set :deploy_to, '/web/parlo-tracker/egstage'
set :rails_env, 'egstage'
set :bundle_dir, "~/.rvm/bin/gems/ruby-2.2.9-p480"
