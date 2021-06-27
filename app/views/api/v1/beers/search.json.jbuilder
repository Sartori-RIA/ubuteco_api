# frozen_string_literal: true

json.array! @beers, partial: 'api/v1/beers/beer', as: :beer
