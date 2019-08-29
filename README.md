tracker
=======

PARLO Progress Tracker

### Installation for development (General)



```bash
https://github.com/21pstem/tracker 
  #Fork repo 
git clone git@github.com:[your github username]/tracker.git
cd tracker
git remote -v
  #origin	https://github.com/[your github username]/tracker.git (fetch)
  #origin	https://github.com/[your github username]/tracker.git (push)
  #upstream	https://github.com/21pstem/tracker.git (fetch)
  #upstream	https://github.com/21pstem/tracker.git (push)
rbenv local version 2.2.9 
  #(set by .../.ruby-version)
cat .ruby-version
  # 2.2.9
bundle install --without=production
cp config/developer/database.yml config/
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake test:prepare
COVERAGE=true bundle exec rspec spec
```

Before ```bundle install --without=production``` can succeed, it may be necessary to install bundler with ```gem install bundler -v 1.17.3```, and other dependencies of this app with specific versions. Appropriate gem install versions can be found in Gemfile.lock in the top level directory of this project.

### Troubleshooting
```bash
  #if problem with bundle install --without=production 
gem install bundler -v 1.17.3
  #libiconv is missing.  please visit
  #http://nokogiri.org/tutorials/installing_nokogiri.html for help with installing
  #dependencies.
gem install nokogiri -v '1.6.3.1' --source 'http://rubygems.org/'
  #if gem install nokogiri -v '1.6.3.1' --source 'http://rubygems.org/' fails because libiconv is missing, 
  #see troubleshooting guide in error message
```



### Create development data

```bash
bundle exec rake initialize_dev:create
```

### Run Local Server 
```
bundle exec rails server
```

### Initialize Server Configuration
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

### Optional Setups

```bash
- load up the training school (takes a while)
bundle exec rake stem_egypt_training_data:build_training_school

- create and load up the keystone high school (takes a while)
bundle exec rake keystone_school:create
```

### Run Tests showing Coverage

```bash
COVERAGE=true bundle exec rspec spec
```
