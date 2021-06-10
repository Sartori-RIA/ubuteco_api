# frozen_string_literal: true

json.array! @beers, partial: 'api/beers/beer', as: :beer
