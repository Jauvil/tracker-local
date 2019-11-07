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
rbenv local version 2.5.6 (for Rails 5)
  #(set by .../.ruby-version)
cat .ruby-version
  # 2.5.6
bundle install --without=production
cp config/developer/database.yml config/
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake db:test:prepare
cp app/assets/images/login_usa_bg.png app/assets/images/login_bg.png

```
### Create First User
```
bundle exec rails console
User.all.count
u = User.new
u.email = 'xxxx'
u.username = 'xxx'
u.temporary_password = 'xxx'
u.password = 'xxx'
u.system_administrator = true
u.first_name = 'xxx'
u.last_name = 'xxx'
u.save
```
### Log into Tracker as first user
```
bundle exec rails server
127.0.0.1:3000
# fill in username and password
# click 'Sign In'
# enter a new password twice (must be different)
# click 'Update Profile'
# fill in username and password
# click 'Sign In'
# optionally edit configuration
# click 'Save'
```
### Initialize Server Configuration
```
http://localhost:3000
username: admin
password: password
click the 'Sign In' button

## Create the Server Configuration record
# Click 'Server Configuration' under System Maint.
# click the edit button (pencil icon)

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

- create the school year record for any additional schools
For every school listed (with no school year)
click the pencil icon on the Model School row
Note: start and end dates should be populated from the Model School
click save
```

### Testing
```
COVERAGE=true bundle exec rspec spec
```


Before ```bundle install --without=production``` can succeed, it may be necessary to install bundler with ```gem install bundler -v 1.17.3```, and other dependencies of this app with specific versions. Appropriate gem install versions can be found in Gemfile.lock in the top level directory of this project.



### Create development data into xxx Seed School

```bash
bundle exec rake initialize_dev:create
```


### Create the Stem Egypt Training School

```bash
- load up the training school (takes a while)
bundle exec rake stem_egypt_training_data:build_training_school
```

### Create the Keystone High School

```bash
- create and load up the keystone high school (takes a while)
bundle exec rake keystone_school:create
```

### Run Local Server
```
bundle exec rails server
```


### Run Tests showing Coverage

```bash
COVERAGE=true bundle exec rspec spec
```


### Set Up Curriculum & School Year Rollover in Development

```bash
# Create a new school (as in Egypt) using system admin web interface
### Schools Page / Add School (+ icon), set year to prior year

# Set up Subjects in Model School to match EG Curriculum
###  Note: this can be rerun if willing to recreate all subjects
bundle exec rake stem_egypt_model_subjects:populate

# Load up initial EG curriculum into model school
Schools Listing / Model School / Upload Learning Outcomes
### Automatically Updated Subjects counts: Updates - 0 , Adds - 648 , Deactivates - 0 , Errors - 0

# update to new curriculum into model school

```

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

