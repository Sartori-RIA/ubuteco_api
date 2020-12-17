require "cpf_cnpj"

FactoryBot.define do
  factory :organization do
    name { Faker::Company.unique.name }
    cnpj { Faker::Company.unique.brazilian_company_number }
    sequence(:phone) {|n| "429999-999#{n}"}
    association :user, factory: :user_admin
  end
end
