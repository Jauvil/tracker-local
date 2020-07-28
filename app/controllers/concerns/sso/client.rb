module Sso
  module Client
    include Headers

    BASE_URL = 'http://localhost:3000'

    def perform_sso_get(path, token=nil)
      HTTParty.get(BASE_URL + path, headers: sso_headers(token)).parsed_response
    end

    def perform_sso_post(path, body={}, token=nil)
      HTTParty.post(BASE_URL + path, body: body, headers: sso_headers(token)).parsed_response
    end

    def perform_sso_put(path, body={}, token=nil)
      HTTParty.put(BASE_URL + path, body: body, headers: sso_headers(token)).parsed_response
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