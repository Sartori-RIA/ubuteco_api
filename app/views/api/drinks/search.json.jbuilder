# frozen_string_literal: true

json.array! @drinks, partial: 'api/drinks/drink', as: :drink
