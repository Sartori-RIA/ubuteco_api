# frozen_string_literal: true

FactoryBot.define do
  factory :beer_style do
    name { Faker::Beer.unique.style }
  end
end
