# frozen_string_literal: true

json.extract! drink,
              :id,
              :name,
              :price_cents,
              :price_currency,
              :quantity_stock,
              :description,
              :flavor,
              :abv,
              :image_url,
              :created_at,
              :updated_at
