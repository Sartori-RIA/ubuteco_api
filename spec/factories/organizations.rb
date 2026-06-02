# frozen_string_literal: true


FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "organization_#{n}" }
    phone { Faker::PhoneNumber.unique.phone_number }

    association :user, factory: [:user, :admin]

    after(:create) do |organization, _evaluator|
      organization.user.update(organization: organization)
    end

    trait :usd do
      locale { 'en' }
      default_currency { 'USD' }
      timezone { 'America/New_York' }
    end
  end
end
