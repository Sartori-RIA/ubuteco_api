# frozen_string_literal: true

FactoryBot.define do
  factory :wine_style do
    sequence(:name) { |n| n }
  end
end
