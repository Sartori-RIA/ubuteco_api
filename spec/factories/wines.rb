# frozen_string_literal: true

FactoryBot.define do
  factory :wine do
    sequence(:name) { |n| "wine_#{n}" }
    quantity_stock { 20 }
    image { Faker::LoremFlickr.image }
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

    trait :reindex do
      after(:create) do |product, _evaluator|
        product.reindex(refresh: true)
      end
    end
  end
end
