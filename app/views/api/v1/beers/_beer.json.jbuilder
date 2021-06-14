# frozen_string_literal: true

json.extract! beer,
              :id, :name, :price_cents, :price_currency, :image, :quantity_stock, :description,
              :abv, :ibu, :valid_until, :created_at, :updated_at

if beer.beer_style.present?
  json.beer_style_id beer.beer_style_id
  json.beer_style do
    json.partial! 'api/v1/beer_styles/beer_style', beer_style: beer.beer_style
  end
end

if beer.maker.present?
  json.maker_id beer.maker_id
  json.maker do
    json.partial! 'api/v1/makers/maker', maker: beer.maker
  end
end
