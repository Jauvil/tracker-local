set :stage, :egstage
server 'egstage.parloproject.org', roles: %w{web app db}
set :rvm_ruby_version, '2.5.6'
set :deploy_to, '/web/parlo-tracker/egstage'
set :rails_env, 'egstage'
# set :bundle_dir seems to be ignored. Currently goes to ~/.rvm/gems/ruby-2.5.6/bin/bundler
#set :bundle_dir, "~/.rvm/bin/gems/ruby-2.2.9-p480"
