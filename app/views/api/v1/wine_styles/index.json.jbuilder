# frozen_string_literal: true

json.data do
  json.array! @records do |wine_style|
    json.partial! 'wine_style', wine_style: wine_style
  end
end

json.partial! '/api/shared/meta'
