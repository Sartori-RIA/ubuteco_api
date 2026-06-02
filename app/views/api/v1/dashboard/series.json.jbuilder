# frozen_string_literal: true

json.metric @series[:metric]
json.grain @series[:grain]
json.currency @series[:currency]
json.from @series[:from]
json.to @series[:to]
json.points @series[:points] do |point|
  json.date point[:date]
  json.value point[:value]
end
