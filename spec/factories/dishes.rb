# frozen_string_literal: true

FactoryBot.define do
  factory :dish do
    sequence(:name) { |n| "dish_#{n}" }
    price { 10.0 }
    organization

    trait :with_ingredients do
      transient do
        ingredients_count { 5 }
      end

      after(:create) do |dish, evaluator|
        evaluator.ingredients_count.times do
          food = create(:food, organization: dish.organization)
          create(:dish_ingredient, dish: dish, food: food)
        end
        dish.reload
      end
    end
  end
end
