# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    total { 10 }
    total_with_discount { 10 }
    discount { 10 }
    organization

    trait :with_items do
      transient do
        items_count { 5 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item, evaluator.items_count, :with_dish, order: order)
        create_list(:order_item, evaluator.items_count, :with_drink, order: order)
        create_list(:order_item, evaluator.items_count, :with_beer, order: order)
        create_list(:order_item, evaluator.items_count, :with_wine, order: order)
      end
    end

    trait :with_dish do
      transient do
        items_count { 5 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item, evaluator.items_count, :with_dish, order: order)
      end
    end
  end
end
