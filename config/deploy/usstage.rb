set :stage, :usstage
server 'usstage.parloproject.org', roles: %w{web app db}
set :rvm_ruby_version, '2.5.6'
set :deploy_to, '/web/parlo-tracker/usstage'
set :rails_env, 'usstage'
set :bundle_dir, "~/.rvm/bin/gems/ruby-2.2.9-p480"
