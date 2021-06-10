# frozen_string_literal: true

json.extract! beer,
              :id,
              :name,
              :price_cents,
              :price_currency,
              :image,
              :quantity_stock,
              :description,
              :abv,
              :ibu,
              :maker,
              :beer_style_id,
              :beer_style,
              :valid_until,
              :created_at,
              :updated_at
