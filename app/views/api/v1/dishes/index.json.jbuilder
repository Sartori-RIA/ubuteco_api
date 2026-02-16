# frozen_string_literal: true

json.data do
  json.array! @records do |dish|
    json.partial! 'dish', dish: dish
  end
end

json.partial! '/api/shared/meta'
