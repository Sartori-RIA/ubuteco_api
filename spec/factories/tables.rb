FactoryBot.define do
  factory :table do
    sequence(:name) { |n| "table name#{n}" }
    sequence(:chairs) { |n| 2 }
    user
  end
end
