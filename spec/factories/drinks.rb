# frozen_string_literal: true

FactoryBot.define do
  factory :drink do
    sequence(:name) { |n| "drink_#{n}" }
    quantity_stock { 3 }
    maker
    organization
  end
end
