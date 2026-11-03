# frozen_string_literal: true

class SupportSessionMailer < ApplicationMailer
  def started
    @session = params[:session]
    @recipient = params[:recipient]
    @actor = @session.actor
    locale = @session.organization.locale.presence || I18n.default_locale
    I18n.with_locale(locale) do
      mail to: @recipient.email, subject: t('support_session.mail.subject')
    end
  end
end
