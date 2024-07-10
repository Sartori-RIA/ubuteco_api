# frozen_string_literal: true


FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "organization_#{n}" }
    phone { Faker::PhoneNumber.unique.phone_number }
    user { association :user, :admin }
    logo { Faker::LoremFlickr.image }

    after(:create) do |organization, _evaluator|
      organization.user.update(organization: organization)
    end

    trait :reindex do
      after(:create) do |product, _evaluator|
        product.reindex(refresh: true)
      end
    end
  end
end
