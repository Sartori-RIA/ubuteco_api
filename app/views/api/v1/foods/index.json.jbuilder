# frozen_string_literal: true

json.data do
  json.array! @records do |food|
    json.partial! 'food', food: food
  end
end

json.partial! '/api/shared/meta'
