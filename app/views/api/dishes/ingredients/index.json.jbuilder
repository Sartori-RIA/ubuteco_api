# frozen_string_literal: true

json.array! @ingredients, partial: 'api/dishes/ingredients/ingredient', as: :ingredient
