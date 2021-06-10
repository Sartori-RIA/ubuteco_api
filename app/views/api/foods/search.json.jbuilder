# frozen_string_literal: true

json.array! @foods, partial: 'api/foods/food', as: :food
