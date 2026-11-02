# frozen_string_literal: true

json.from @from.iso8601
json.to @to.iso8601
json.items @items do |item|
  json.organization_id item.organization_id
  json.organization_name item.organization_name
  json.feature item.feature
  json.day item.day.iso8601
  json.calls item.calls
  json.input_tokens item.input_tokens
  json.output_tokens item.output_tokens
  json.failed_calls item.failed_calls
end
