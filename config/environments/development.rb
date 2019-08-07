Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  # # This was removed by the rake app:update to Rails 4.0 ????
  # config.action_view.debug_rjs             = true

  # Do care if the mailer can't send.
  # # This was turned off by the rake app:update to Rails 4.0
  # config.action_mailer.raise_delivery_errors = true
  # # Don't care if the mailer can't send.
  # # This was set by the rake app:update to Rails 4.0
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Expands the lines which load the assets
  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Do not compress assets
  config.assets.compress = false

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Open emails to be sent in a new browser window.
  config.action_mailer.delivery_method = :letter_opener

  # run delayed jobs inline for development
  Delayed::Worker.delay_jobs = false

end
