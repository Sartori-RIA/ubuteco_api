# frozen_string_literal: true

class Product < ApplicationRecord
  self.abstract_class = true

  acts_as_paranoid

  has_many :order_items, as: :item, dependent: :restrict_with_error

  validates :name, :price, presence: true

  has_one_attached :image

  monetize :price_cents

  def image_url
    if image.attached?
      Rails.application.routes.url_helpers.url_for(
        image.variant(resize_to_limit: [100, 100]).processed
      )
    else
      "#{Rails.application.routes.default_url_options[:protocol] || 'http'}://" \
        "#{Rails.application.routes.default_url_options[:host]}" \
        "#{Rails.application.routes.default_url_options[:port] ? ":#{Rails.application.routes.default_url_options[:port]}" : ""}" \
        "#{ActionController::Base.helpers.asset_path('images/default.png')}"
    end
  end
end
