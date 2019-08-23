set :stage, :enstage
server 'enstage.parloproject.org', roles: %w{web app db}
set :rvm_ruby_version, '2.2.9'
set :deploy_to, '/web/parlo-tracker/enstage'
set :rails_env, 'enstage'
set :bundle_dir, "~/.rvm/bin/gems/ruby-2.2.9-p480"
