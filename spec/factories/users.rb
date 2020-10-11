# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name {'Admin'}
    sequence(:email) { |n| "admin#{n}@email.com"}
    sequence(:company_name) { |n| "company_#{n}"}
    password {'password'}
    cnpj { Faker::CNPJ.pretty }
  end
end
