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
bundle exec rake test:prepare
COVERAGE=true bundle exec rspec spec
```
Run Tests showing Coverage

```bash
COVERAGE=true bundle exec rspec spec
```
