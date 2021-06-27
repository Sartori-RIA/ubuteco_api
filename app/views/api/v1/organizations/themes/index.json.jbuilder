# frozen_string_literal: true

json.array! @themes, partial: 'api/v1/organizations/themes/theme', as: :theme
