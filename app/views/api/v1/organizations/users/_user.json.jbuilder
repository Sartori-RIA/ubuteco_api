# frozen_string_literal: true

json.extract! user,
              :id,
              :email,
              :name,
              :organization_id,
              :role,
              :role_id,
              :created_at,
              :updated_at

if user.avatar.attached?
  json.avatar do
    json.url url_for(user.avatar)
    json.filename user.avatar.filename.to_s
    json.content_type user.avatar.content_type
  end
end
