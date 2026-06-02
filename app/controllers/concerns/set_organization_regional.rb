# frozen_string_literal: true

module SetOrganizationRegional
  extend ActiveSupport::Concern

  included do
    around_action :apply_organization_regional_settings
  end

  private

  def apply_organization_regional_settings
    org = regional_organization
    locale = org&.locale.presence || I18n.default_locale
    currency = org&.default_currency.presence || Money.default_currency.iso_code
    timezone = org&.timezone.presence || Time.zone.name

    I18n.with_locale(locale) do
      with_default_currency(currency) do
        Time.use_zone(timezone) { yield }
      end
    end
  end

  def with_default_currency(currency)
    previous = Money.default_currency
    Money.default_currency = Money::Currency.wrap(currency)
    yield
  ensure
    Money.default_currency = previous
  end

  def regional_organization
    Current.organization || current_user&.organization
  end
end
