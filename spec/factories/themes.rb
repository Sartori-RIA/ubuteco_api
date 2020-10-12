# frozen_string_literal: true

FactoryBot.define do
  factory :theme do
    color_header { 'white' }
    color_sidebar { 'white' }
    color_footer { 'white' }
    user
  end
end
