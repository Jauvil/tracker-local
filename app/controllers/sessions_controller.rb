class SessionsController < Devise::SessionsController
  include SsoSessions
end
