# frozen_string_literal: true

json.array! @organizations, partial: 'api/v1/organizations/organization', as: :organization
