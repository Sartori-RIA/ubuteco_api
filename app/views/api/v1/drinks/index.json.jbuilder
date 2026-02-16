# frozen_string_literal: true

json.data do
  json.array! @records do |drink|
    json.partial! 'drink', drink: drink
  end
end

json.partial! '/api/shared/meta'
