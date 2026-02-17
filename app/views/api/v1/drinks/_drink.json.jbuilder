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
              :created_at,
              :updated_at

if drink.image.attached?
  json.image do
    json.url url_for(drink.image)
    json.filename drink.image.filename.to_s
    json.content_type drink.image.content_type
  end
end

if drink.maker.present?
  json.maker_id drink.maker_id
  json.maker do
    json.partial! 'api/v1/makers/maker', maker: drink.maker
  end
end
