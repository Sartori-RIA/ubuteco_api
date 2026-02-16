# frozen_string_literal: true

json.data do
  json.array! @records do |table|
    json.partial! 'table', table: table
  end
end

json.partial! '/api/shared/meta'
