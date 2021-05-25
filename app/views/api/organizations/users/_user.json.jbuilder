json.extract! user,
              :id,
              :email,
              :name,
              :organization_id,
              :role,
              :role_id,
              :created_at,
              :updated_at

json.organization do
  json.partial! 'api/organizations/organization', organization: user.organization
end
