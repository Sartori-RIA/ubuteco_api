# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    total { 10 }
    total_with_discount { 10 }
    discount { 10 }
    table
    organization
    association :customer, factory: :user

    factory :order_with_items do
      transient do
        items_count { 5 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item_drink, evaluator.items_count, order: order)
        create_list(:order_item_beer, evaluator.items_count, order: order)
        create_list(:order_item_dish, evaluator.items_count, order: order)
        create_list(:order_item_wine, evaluator.items_count, order: order)
      end
    end

    factory :order_with_dish do
      transient do
        items_count { 5 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item_dish, evaluator.items_count, order: order)
      end
    end
  end
end
