# frozen_string_literal: true

FactoryBot.define do
  factory :order_item do
    order
    quantity { 2 }

    trait :with_drink do
      association :item, factory: :drink
    end

    trait :with_beer do
      association :item, factory: :beer
    end

    trait :with_dish do
      association :item, factory: :dish
    end
    trait :with_wine do
      association :item, factory: :wine
    end
  end
end
