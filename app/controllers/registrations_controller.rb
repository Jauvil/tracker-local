class RegistrationsController < Devise::RegistrationsController
  include SsoRegistrations


end