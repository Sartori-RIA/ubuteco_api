# frozen_string_literal: true

json.extract! drink,
              :id,
              :name,
              :price_cents,
              :price_currency,
              :quantity_stock,
              :description,
              :flavor,
              :abv,
              :image_url,
              :created_at,
              :updated_at

if drink.maker.present?
  json.maker_id drink.maker_id
  json.maker do
    json.partial! 'api/v1/makers/maker', maker: drink.maker
  end
end
