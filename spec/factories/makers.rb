# frozen_string_literal: true

FactoryBot.define do
  factory :maker do
    name { Faker::Company.name }
    country { Faker::Address.country }
    organization

    trait :reindex do
      after(:create) do |product, _evaluator|
        product.reindex(refresh: true)
      end
    end
  end
end
