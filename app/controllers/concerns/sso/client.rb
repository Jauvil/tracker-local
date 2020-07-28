module Sso

  module Client
    include Headers
    include Constants

    def perform_sso_get(path, token=nil)
      HTTParty.get(secrets['sso_url'] + path, headers: sso_headers(token)).parsed_response
    end

    def perform_sso_post(path, body={}, token=nil)
      HTTParty.post(secrets['sso_url'] + path, body: body, headers: sso_headers(token)).parsed_response
    end

    def perform_sso_put(path, body={}, token=nil)
      HTTParty.put(secrets['sso_url'] + path, body: body, headers: sso_headers(token)).parsed_response
    end

    def build_user_create_body(user)
      {
          user: {
              email: user.email,
              password: user.temporary_password,
              password_confirmation: user.temporary_password,
              roles: JSON.parse(user.role_symbols.to_json),
              component: 'tracker'
          }
      }.to_json
    end
  end
end
