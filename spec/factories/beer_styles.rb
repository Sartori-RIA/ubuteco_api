# frozen_string_literal: true

FactoryBot.define do
  factory :beer_style do
    sequence(:name) { |n| n }
    user
  end
end
