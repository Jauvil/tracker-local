tracker
=======

PARLO Progress Tracker

Installation for development

```bash
git clone git@github.com:21pstem/tracker.git
cd tracker
rbenv version
  # 2.0.0-p648
  # (set by ./.ruby-version)
cat .ruby-version
  # 2.0.0-p648
bundle install --without=production
cp config/developer/database.yml config/
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake test:prepare
COVERAGE=true bundle exec rspec spec
```

Create development data

```bash
bundle exec rake initialize_dev:create
```
Initialize Server Configuration

```
http://localhost:3000
username: admin
password: password
click the 'Sign In' button
click the _Server Configuration_ link with ERROR
click the pencil icon in the upper right to edit the configuration
- will return ERROR: Server Config did not exist, Default one Created, Please Edit! 
Please change at least the Support Email address
click the 'Save' button

```

Run Tests showing Coverage

```bash
COVERAGE=true bundle exec rspec spec
```
