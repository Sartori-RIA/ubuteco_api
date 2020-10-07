FactoryBot.define do
  factory :beer do
    sequence(:name) { |n| "Beer_#{n}" }
    ibu {2}
    abv {2}
    price {10}
    quantity_stock {3}
    beer_style
    maker
    user
  end
end
