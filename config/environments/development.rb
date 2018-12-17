Tracker2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # # This was turned off by the rake app:update to Rails 4.0 ????
  # config.whiny_nils = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  # # This was removed by the rake app:update to Rails 4.0 ????
  # config.action_view.debug_rjs             = true

  # Do care if the mailer can't send.
  # # This was turned off by the rake app:update to Rails 4.0 ????
  config.action_mailer.raise_delivery_errors = true
  # # Don't care if the mailer can't send.
  # # This was set by the rake app:update to Rails 4.0 ????
  # config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  # # This was removed by the rake rails:update to Rails 4.0 ????
  # config.action_dispatch.best_standards_support = :builtin

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # # This was added by the rake rails:update to Rails 4.0 ????
  # config.assets.debug = true

    # Do not compress assets
  # # This was removed by the rake rails:update to Rails 4.0 ????
  config.assets.compress = false

  # Expands the lines which load the assets
  # # This was removed by the rake rails:update to Rails 4.0 ????
  config.assets.debug = false


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true


  # Open emails to be sent in a new browser window.
  # # This was removed by the rake rails:update to Rails 4.0 ????
  config.action_mailer.delivery_method = :letter_opener

  # run delayed jobs inline for development
  # # This was removed by the rake rails:update to Rails 4.0 ????
  Delayed::Worker.delay_jobs = false

end
