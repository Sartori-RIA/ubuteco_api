# frozen_string_literal: true

json.extract! ingredient,
              :id,
              :quantity,
              :food_id,
              :created_at,
              :updated_at

json.food do
  json.call(ingredient.food, :id, :name)
end
