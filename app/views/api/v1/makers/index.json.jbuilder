# frozen_string_literal: true

json.data do
  json.array! @records do |maker|
    json.partial! 'maker', maker: maker
  end
end

json.partial! '/api/shared/meta'
