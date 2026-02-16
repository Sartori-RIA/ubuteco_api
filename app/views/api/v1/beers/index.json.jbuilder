# frozen_string_literal: true

json.data do
  json.array! @records do |beer|
    json.partial! 'beer', beer: beer
  end
end

json.partial! '/api/shared/meta'
