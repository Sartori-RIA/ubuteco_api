# frozen_string_literal: true

FactoryBot.define do
  factory :table do
    sequence(:name) { |n| "#{Faker::Name.name}_#{n}" }
    sequence(:chairs) { |_n| 2 }
    organization
  end
end
