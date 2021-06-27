# frozen_string_literal: true

json.array! @makers, partial: 'api/v1/makers/maker', as: :maker
