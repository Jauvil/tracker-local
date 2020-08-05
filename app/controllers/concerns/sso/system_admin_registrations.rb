module Sso
  module SystemAdminRegistrations
    include Client

    class ServerConnectionError < StandardError
      def message
        'There was a problem communicating with the single sign on server'
      end
    end

    def system_administrator
      super { |user| perform_sso_signup(user) }
    end

    def staff
      super { |user| perform_sso_signup(user) }
    end

    def student
      super { |user| perform_sso_signup(user) }
    end

    def perform_sso_signup(user)
      resp = perform_sso_post('/users', build_user_create_body(user), session[:jwt_token])
      puts resp.inspect.red
    end
  end
end
