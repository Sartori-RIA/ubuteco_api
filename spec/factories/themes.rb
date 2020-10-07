# frozen_string_literal: true

FactoryBot.define do
  factory :theme do
    color_header { 'MyString' }
    color_sidebar { 'MyString' }
    color_footer { 'MyString' }
    rtl { false }
  end
end
