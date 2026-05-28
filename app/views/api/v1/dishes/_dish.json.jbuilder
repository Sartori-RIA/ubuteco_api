# frozen_string_literal: true

json.extract! dish,
              :id,
              :name,
              :price_cents,
              :price_currency,
              :image_url,
              :thumbnail_url,
              :created_at,
              :updated_at

json.dish_ingredients do
  json.array! dish.dish_ingredients, partial: 'api/v1/dishes/ingredients/ingredient', as: :ingredient
end
