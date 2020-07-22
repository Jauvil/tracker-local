module Sso
  module SystemAdminRegistrations
  include TokenParser, Client

    def create_system_user
      super do |user|
        perform_sso_signup(user)
      end
    end

    def create_staff_user
      super do |user|
        perform_sso_signup(user)
      end
    end

    def create_student_user
      super do |user|
        perform_sso_signup(user)
      end
    end

    def perform_sso_signup(user)
      # token = encode_token(payload)
      response = perform_sso_post('/users', build_user_create_body(user))
    end
  end
end