# frozen_string_literal: true

json.data do
  json.array! @records do |organization|
    json.partial! 'api/v1/organizations/organization', organization: organization
  end
end

json.partial! '/api/shared/meta'
