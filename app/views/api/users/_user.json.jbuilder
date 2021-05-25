json.extract! user, :id, :email, :name, :created_at, :updated_at

if user.role.present?
  json.role do
    json.partial! 'api/roles/role', role: user.role
  end
end

if user.organization.present?
  json.organization do
    json.partial! 'api/organizations/organization', organization: user.organization
  end
end
