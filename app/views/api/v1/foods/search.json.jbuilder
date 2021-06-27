# frozen_string_literal: true

json.array! @foods, partial: 'api/v1/foods/food', as: :food
