# frozen_string_literal: true

json.array! @kitchens, partial: 'api/v1/kitchens/kitchen', as: :kitchen
