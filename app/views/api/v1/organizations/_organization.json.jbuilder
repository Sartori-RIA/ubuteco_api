# frozen_string_literal: true

json.extract! organization,
              :id,
              :name,
              :phone,
              :user_id,
              :operational_status,
              :logo_url,
              :created_at,
              :updated_at

if organization.theme.present?
  json.theme do
    json.partial! partial: 'api/v1/organizations/themes/theme', theme: organization.theme, as: :theme
  end
end
