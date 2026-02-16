# frozen_string_literal: true

json.data do
  json.array! @records do |customer|
    json.partial! 'customer', customer: customer
  end
end

json.partial! '/api/shared/meta'
