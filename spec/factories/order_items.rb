FactoryBot.define do
  factory :order_item do
    order { nil }
    quantity { "" }
    item { nil }
    user
  end
end
