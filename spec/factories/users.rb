# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'Admin' }
    sequence(:email) { |n| "admin#{n}@email.com" }
    password { 'password' }
    organization
    factory :user_admin do
      association :role, factory: :admin
    end
    factory :user_staff do
      association :role, factory: :staff
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
