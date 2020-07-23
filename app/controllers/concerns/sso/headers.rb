module Sso
  module Headers
    def sso_headers(token=nil)
      headers = {}
      headers['Authorization'] = token if token.present?
      headers['Content-Type'] = 'application/json'
      headers['Accept'] = 'application/json'
      headers
    end
  end
end
