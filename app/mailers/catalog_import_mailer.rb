# frozen_string_literal: true

class CatalogImportMailer < ApplicationMailer
  def finished
    @import = params[:import]
    I18n.with_locale(@import.organization.locale) do
      mail to: @import.user.email, subject: I18n.t('catalog_import_mailer.finished.subject')
    end
  end
end
