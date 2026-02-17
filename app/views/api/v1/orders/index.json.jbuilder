# frozen_string_literal: true

json.data do
  json.array! @records do |order|
    json.partial! 'order', order: order
  end
end

json.partial! '/api/shared/meta'
