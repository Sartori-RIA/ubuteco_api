# frozen_string_literal: true

json.array! @kitchens, partial: 'api/kitchens/kitchen', as: :kitchen
