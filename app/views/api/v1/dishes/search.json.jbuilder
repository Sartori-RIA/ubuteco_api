# frozen_string_literal: true

json.array! @dishes, partial: 'api/v1/dishes/dish', as: :dish
