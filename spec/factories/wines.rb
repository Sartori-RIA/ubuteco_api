# frozen_string_literal: true

FactoryBot.define do
  factory :wine do
    name { Faker::Beer.name }
    quantity_stock { 20 }
    image { Faker::LoremPixel.image }
    abv { 30 }
    price { 10 }
    description { Faker::Lorem.paragraph }
    vintage_wine { 2010 }
    visual { 'MyString' }
    ripening { 'Ripening' }
    grapes { 'MyString' }
    organization
    maker
    wine_style
  end
end
