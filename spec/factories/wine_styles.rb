# frozen_string_literal: true

FactoryBot.define do
  factory :wine_style do
    sequence(:name) { |n| "wines_style_#{n}" }
  end
end
