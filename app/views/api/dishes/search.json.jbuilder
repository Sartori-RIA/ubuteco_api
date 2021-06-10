# frozen_string_literal: true

json.array! @dishes, partial: 'api/dishes/dish', as: :dish
