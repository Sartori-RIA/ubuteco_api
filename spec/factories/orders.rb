# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    total { 10 }
    total_with_discount { 10 }
    discount { 10 }
    organization
    status { 0 }

    trait :open do
      status { 0 }
    end
    trait :closed do
      status { 1 }
    end
    trait :payed do
      status { 2 }
    end
    trait :with_items do
      transient do
        items_count { 5 }
      end

      after(:create) do |order, evaluator|
        org = order.organization
        evaluator.items_count.times do
          create(:order_item, order: order, item: create(:dish, organization: org))
          create(:order_item, order: order, item: create(:drink, organization: org))
          create(:order_item, order: order, item: create(:beer, organization: org, maker: create(:maker, organization: org)))
          create(:order_item, order: order, item: create(:wine, organization: org, maker: create(:maker, organization: org)))
        end
      end
    end

    trait :with_dish do
      transient do
        items_count { 5 }
      end

      after(:create) do |order, evaluator|
        org = order.organization
        create_list(
          :order_item,
          evaluator.items_count,
          order: order,
          item: create(:dish, organization: org)
        )
      end
    end
  end
end
