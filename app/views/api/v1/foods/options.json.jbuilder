# frozen_string_literal: true

json.data @foods do |food|
  json.id food.id
  json.name food.name
end
