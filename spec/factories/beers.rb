# frozen_string_literal: true

FactoryBot.define do
  factory :beer do
    name { Faker::Beer.name }
    ibu { 2 }
    abv { 2 }
    price { 10 }
    quantity_stock { 3 }
    beer_style
    maker
    organization
  end
end
