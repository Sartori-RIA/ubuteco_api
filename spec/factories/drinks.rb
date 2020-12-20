# frozen_string_literal: true

FactoryBot.define do
  factory :drink do
    name { Faker::Beer.name }
    quantity_stock { 3 }
    maker
    organization
  end
end
