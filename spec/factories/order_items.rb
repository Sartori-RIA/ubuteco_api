# frozen_string_literal: true

FactoryBot.define do
  factory :order_item do
    order
    quantity { 2 }

    factory :order_item_drink do
      association :item, factory: :drink
    end

    factory :order_item_beer do
      association :item, factory: :beer
    end

    factory :order_item_dish do
      association :item, factory: :dish
    end
    factory :order_item_wine do
      association :item, factory: :wine
    end
  end
end
