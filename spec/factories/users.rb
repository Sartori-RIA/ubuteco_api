# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user_#{n}" }
    sequence(:email) { |n| "admin#{n}@email.com" }
    avatar { Faker::LoremPixel.image }
    password { 'password' }
    role
    factory :user_with_organization do
      association :organization, factory: :organization
    end
    factory :user_admin do
      association :role, factory: :admin
    end
    factory :user_super_admin do
      association :role, factory: :super_admin
    end
    factory :user_kitchen do
      association :role, factory: :kitchen
    end
    factory :user_waiter do
      association :role, factory: :waiter
    end
    factory :user_cash_register do
      association :role, factory: :cash_register
    end
    factory :user_customer do
      association :role, factory: :customer
    end
  end
end
