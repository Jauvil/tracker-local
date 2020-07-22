module Sso
  module AdminUserRegistrations
    include Client

    def create
      super do |user|
        response = perform_sso_post('/users', build_user_create_body(user))
        Rails.logger.debug("Admin User Registrations - #{response.inspect}")
      end
    end
  end
end
