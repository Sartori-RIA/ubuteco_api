require "cpf_cnpj"

FactoryBot.define do
  factory :organization do
    name { Faker::Company.unique.name }
    cnpj { Faker::Company.unique.brazilian_company_number }
    phone { Faker::PhoneNumber.unique.phone_number }
    association :user, factory: :user_admin
    logo { Faker::LoremPixel.image }
  end
end
