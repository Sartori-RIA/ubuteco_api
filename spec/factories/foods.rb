# frozen_string_literal: true

FactoryBot.define do
  factory :food do
    name { Faker::Food.ingredient }
    price { 1.0 }
    quantity_stock { 10 }
    organization
  end
end
