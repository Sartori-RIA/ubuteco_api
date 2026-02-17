# frozen_string_literal: true

json.extract! dish,
              :id,
              :name,
              :price_cents,
              :price_currency,
              :created_at,
              :updated_at

json.dish_ingredients do
  json.array! dish.dish_ingredients, partial: 'api/v1/dishes/ingredients/ingredient', as: :ingredient
end

if dish.image.attached?
  json.image do
    json.url url_for(dish.image)
    json.filename dish.image.filename.to_s
    json.content_type dish.image.content_type
  end
end
