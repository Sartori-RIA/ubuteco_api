# frozen_string_literal: true

json.extract! wine,
              :id,
              :name,
              :quantity_stock,
              :abv,
              :price_cents,
              :price_currency,
              :description,
              :vintage_wine,
              :visual,
              :ripening,
              :grapes,
              :organization_id,
              :organization,
              :created_at,
              :updated_at

if wine.image.attached?
  json.image do
    json.url url_for(wine.image)
    json.filename wine.image.filename.to_s
    json.content_type wine.image.content_type
  end
end



if wine.wine_style.present?
  json.wine_style_id wine.wine_style_id
  json.wine_style do
    json.partial! 'api/v1/wine_styles/wine_style', wine_style: wine.wine_style
  end
end

if wine.maker.present?
  json.maker_id wine.maker_id
  json.maker do
    json.partial! 'api/v1/makers/maker', maker: wine.maker
  end
end
