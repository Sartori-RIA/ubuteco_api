# frozen_string_literal: true

json.extract! organization,
              :id,
              :name,
              :cnpj,
              :phone,
              :logo,
              :user_id,
              :created_at,
              :updated_at

if organization.theme.present?
  json.theme do
    json.partial! partial: 'api/v1/organizations/themes/theme', theme: organization.theme, as: :theme
  end
end
