# frozen_string_literal: true

FactoryBot.define do
  factory :dish do
    name { Faker::Food.dish }
    price { 10.0 }
    organization

    factory :dish_with_ingredients do
      transient do
        ingredients_count { 5 }
      end

      after(:create) do |dish, evaluator|
        create_list(:dish_ingredient, evaluator.ingredients_count, dish: dish)
      end
    end
  end
end
