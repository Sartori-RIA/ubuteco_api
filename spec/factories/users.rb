# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user_#{n}" }
    sequence(:email) { |n| "admin#{n}@email.com" }
    avatar { Faker::LoremPixel.image }
    password { 'password' }
    role
    trait :with_organization do
      association :organization, factory: :organization
    end
    trait :admin do
      association :role, factory: :admin
    end
    trait :super_admin do
      association :role, factory: :super_admin
    end
    trait :kitchen do
      association :role, factory: :kitchen
    end
    trait :waiter do
      association :role, factory: :waiter
    end
    trait :cash_register do
      association :role, factory: :cash_register
    end
    trait :customer do
      association :role, factory: :customer
    end
  end
end
