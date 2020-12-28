# frozen_string_literal: true

FactoryBot.define do
  factory :dish do
    sequence(:name) { |n| "dish_#{n}" }
    price { 10.0 }
    organization

    trait :with_ingredients do
      transient do
        ingredients_count { 5.0 }
      end

      after(:create) do |dish, evaluator|
        create_list(:dish_ingredient, evaluator.ingredients_count, dish: dish,)
      end
    end
  end
end
