# frozen_string_literal: true

FactoryBot.define do
  factory :maker do
    name { Faker::Company.unique.name }
    sequence(:country) { |n| "country #{n}" }
    organization
  end
end
