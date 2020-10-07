FactoryBot.define do
  factory :beer_style do
    sequence(:name) { |n| n }
    user
  end
end
