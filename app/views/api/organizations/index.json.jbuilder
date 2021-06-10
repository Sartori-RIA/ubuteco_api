# frozen_string_literal: true

json.array! @organizations, partial: 'api/organizations/organization', as: :organization
