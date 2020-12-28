# frozen_string_literal: true

FactoryBot.define do
  factory :food do
    sequence(:name) { |n| "food_#{n}" }
    price { 1.0 }
    quantity_stock { 10 }
    organization
  end
end
