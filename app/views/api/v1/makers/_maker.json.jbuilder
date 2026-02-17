# frozen_string_literal: true

json.extract! maker,
              :id,
              :name,
              :country,
              :created_at,
              :updated_at

if maker.image.attached?
  json.image do
    json.url url_for(maker.image)
    json.filename maker.image.filename.to_s
    json.content_type maker.image.content_type
  end
end
