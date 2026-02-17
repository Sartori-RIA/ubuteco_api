# frozen_string_literal: true

json.data do
  json.array! @records do |wine|
    json.partial! 'wine', wine: wine
  end
end

json.partial! '/api/shared/meta'
