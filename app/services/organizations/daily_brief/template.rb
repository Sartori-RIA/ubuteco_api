# frozen_string_literal: true

module Organizations
  module DailyBrief
    class Template
      def self.call(facts)
        locale = facts[:locale].presence || I18n.default_locale
        I18n.with_locale(locale) do
          key = facts[:revenue_delta_percent].nil? ? 'dashboard.brief.template_without_delta' : 'dashboard.brief.template'
          I18n.t(
            key,
            yesterday_revenue: facts[:yesterday_revenue],
            revenue_delta_percent: facts[:revenue_delta_percent],
            yesterday_orders: facts[:yesterday_orders],
            yesterday_average_ticket: facts[:yesterday_average_ticket],
            today_revenue: facts[:today_revenue],
            today_orders: facts[:today_orders],
            top_products: product_list(facts[:top_products]),
            low_stock_count: facts[:low_stock_count],
            expiring_count: facts[:expiring_count],
            avg_prep_minutes: facts[:avg_prep_minutes]
          )
        end
      end

      def self.product_list(products)
        return I18n.t('dashboard.brief.no_products') if products.blank?

        products.map { |product| "#{product[:name]} (#{product[:quantity]})" }.join(', ')
      end
    end
  end
end
