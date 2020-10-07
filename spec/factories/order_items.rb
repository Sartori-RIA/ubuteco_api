# frozen_string_literal: true

FactoryBot.define do
  factory :order_item do
    order { nil }
    quantity { '' }
    item { nil }
    user
  end
end
