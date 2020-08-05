module Sso
  module SystemAdminRegistrations
    include Client

    class ServerConnectionError < StandardError
      def message
        'There was a problem communicating with the single sign on server'
      end
    end

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
      perform_sso_post('/users', build_user_create_body(user), session[:jwt_token])
    end
  end
end