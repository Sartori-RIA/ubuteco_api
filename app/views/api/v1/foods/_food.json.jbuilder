# frozen_string_literal: true

json.extract! food,
              :id,
              :name,
              :price_cents,
              :price_currency,
              :image,
              :quantity_stock,
              :valid_until,
              :created_at,
              :updated_at

if food.image.attached?
  json.image do
    json.url url_for(food.image)
    json.filename food.image.filename.to_s
    json.content_type food.image.content_type
  end
end