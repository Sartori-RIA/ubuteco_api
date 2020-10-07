# frozen_string_literal: true

FactoryBot.define do
  factory :table do
    sequence(:name) { |n| "table name#{n}" }
    sequence(:chairs) { |_n| 2 }
    user
  end
end
