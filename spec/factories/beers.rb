# frozen_string_literal: true

FactoryBot.define do
  factory :beer do
    sequence(:name) { |n| "beer_#{n}" }
    ibu { 2 }
    abv { 2 }
    price { 10 }
    quantity_stock { 3 }
    beer_style
    maker
    organization

    trait :reindex do
      after(:create) do |product, _evaluator|
        product.reindex(refresh: true)
      end
    end
  end
end
