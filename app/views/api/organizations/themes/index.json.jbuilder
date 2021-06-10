# frozen_string_literal: true

json.array! @themes, partial: 'api/organizations/themes/theme', as: :theme
