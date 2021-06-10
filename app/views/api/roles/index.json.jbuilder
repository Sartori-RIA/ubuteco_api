# frozen_string_literal: true

json.array! @roles, partial: 'api/roles/role', as: :role
