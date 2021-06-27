# frozen_string_literal: true

json.array! @roles, partial: 'api/v1/roles/role', as: :role
