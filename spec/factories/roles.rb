FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "table name#{n}" }

    factory :role_as_admin do
      name { 'ADMIN' }
    end
    factory :role_as_restaurant do
      name { 'RESTAURANT' }
    end
  end
end
