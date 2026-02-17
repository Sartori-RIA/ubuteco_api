# frozen_string_literal: true

json.extract! organization,
              :id,
              :name,
              :phone,
              :user_id,
              :created_at,
              :updated_at

if organization.logo.attached?
  json.logo do
    json.url url_for(organization.logo)
    json.filename organization.logo.filename.to_s
    json.content_type organization.logo.content_type
  end
end

if organization.theme.present?
  json.theme do
    json.partial! partial: 'api/v1/organizations/themes/theme', theme: organization.theme, as: :theme
  end
end
