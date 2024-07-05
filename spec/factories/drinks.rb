# frozen_string_literal: true

FactoryBot.define do
  factory :drink do
    sequence(:name) { |n| "drink_#{n}" }
    quantity_stock { 3 }
    maker
    organization

    trait :reindex do
      after(:create) do |product, _evaluator|
        product.reindex(refresh: true)
      end
    end
  end
end
