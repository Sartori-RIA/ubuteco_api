# frozen_string_literal: true

json.extract! user, :id, :email, :name, :created_at, :updated_at

if user.avatar.attached?
  json.avatar do
    json.url url_for(user.avatar)
    json.filename user.avatar.filename.to_s
    json.content_type user.avatar.content_type
  end
end

if user.role.present?
  json.role do
    json.partial! 'api/v1/roles/role', role: user.role
  end
end

if user.organization.present?
  json.organization do
    json.partial! 'api/v1/organizations/organization', organization: user.organization
  end
end
