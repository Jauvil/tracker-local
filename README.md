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

- Create the Server Configuration record
click the _Server Configuration_ link with ERROR
click the pencil icon in the upper right to edit the configuration
- will return ERROR: Server Config did not exist, Default one Created, Please Edit!
Please change at least the Support Email address
click the 'Save' button

- create the school year record for the model school
click the _Schools_ link in the Toolkit
click the pencil icon on the Model School row
enter start and end dates (month and year numbers)
click save

- create the lookup records for attendance (Attendance Types and Excuses)
click the _Attendance Maint._ link in the Toolkit
add and save all attendance types and excuses (plus arrows in upper right of each section)
```

Optional Setups

```bash
- load up the training school (takes a while)
bundle exec rake stem_egypt_training_data:build_training_school

- create and load up the keystone high school (takes a while)
bundle exec rake keystone_school:create
```

Run Tests showing Coverage

```bash
COVERAGE=true bundle exec rspec spec
```
