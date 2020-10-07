# frozen_string_literal: true

FactoryBot.define do
  factory :maker do
    sequence(:name) { |n| "name #{n}" }
    sequence(:country) { |n| "country #{n}" }
    user
  end
end
