# frozen_string_literal: true

# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class SystemMailer < ActionMailer::Base
  # removed because test database is empty when this is called
  # default from: ServerConfig.first.support_email, to: ServerConfig.first.support_email

  def onboarding_report(data)
    @data = data
    # TODO: Find out actual emails needed for status report
    mail(from: 'tracker_system@21pstem.org', to: 'justinauvil15@gmail.com', subject: "SSO User Enrollment Report")
  end
end
