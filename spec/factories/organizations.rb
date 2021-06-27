# frozen_string_literal: true

require 'cpf_cnpj'

FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "organization_#{n}" }
    cnpj { Faker::Company.unique.brazilian_company_number }
    phone { Faker::PhoneNumber.unique.phone_number }
    user { association :user, :admin }
    logo { Faker::LoremPixel.image }

    after(:create) do |organization, _evaluator|
      organization.user.update(organization: organization)
    end
  end
end
