# frozen_string_literal: true

FactoryBot.define do
  factory :dish_ingredient do
    quantity { 1 }
    food
  end
end
