module Sso
  module Client
    BASE_URL = 'http://localhost:3000'

    def sso_headers(token=nil)
      headers = {}
      headers['Authorization'] = token if token.present?
      headers['Content-Type'] = 'application/json'
      headers['Accept'] = 'application/json'
      headers
    end

    def perform_sso_get(path, token=nil)
      HTTParty.get(BASE_URL + path, headers: sso_headers(token)).parsed_response
    end

    def perform_sso_post(path, body={}, token=nil)
      HTTParty.post(BASE_URL + path, body: body, headers: sso_headers(token)).parsed_response
    end

    def perform_sso_put(path, body={}, token=nil)
      HTTParty.patch(BASE_URL + path, body: body, headers: sso_headers(token)).parsed_response
    end

    def build_user_create_body(user)
      {
          user: {
              email: user.email,
              password: user.temporary_password,
              password_confirmation: user.temporary_password
          }
      }.to_json
    end
  end
end