FactoryBot.define do
  factory :food do
    sequence(:name) { |n| "food#{n} " }
    price { 1.0 }
    quantity_stock { 10 }
    user
  end
end
