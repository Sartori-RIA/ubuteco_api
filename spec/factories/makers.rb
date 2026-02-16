# frozen_string_literal: true

FactoryBot.define do
  factory :maker do
    name { Faker::Company.name }
    country { Faker::Address.country }
    organization
  end
end
