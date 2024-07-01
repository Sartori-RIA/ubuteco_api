# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_USER_NAME', nil)
  layout 'mailer'
end
