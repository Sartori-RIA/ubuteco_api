# frozen_string_literal: true

json.array! @makers, partial: 'api/makers/maker', as: :maker
