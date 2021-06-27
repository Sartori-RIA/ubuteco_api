# frozen_string_literal: true

json.array! @ingredients, partial: 'api/v1/dishes/ingredients/ingredient', as: :ingredient
