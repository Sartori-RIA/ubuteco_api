# frozen_string_literal: true

json.array! @drinks, partial: 'api/v1/drinks/drink', as: :drink
