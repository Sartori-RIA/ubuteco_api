FactoryBot.define do
  factory :drink do
    sequence(:name) { |n| "Beer_#{n}" }
    quantity_stock {3}
    maker
    user
  end
end
