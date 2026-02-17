# frozen_string_literal: true

json.data do
  json.array! @records do |user|
    json.partial! 'user', user: user
  end
end

json.partial! '/api/shared/meta'

