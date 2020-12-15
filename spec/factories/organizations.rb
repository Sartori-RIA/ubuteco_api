require "cpf_cnpj"

FactoryBot.define do
  factory :organization do
    sequence(:name) {|n| "organization_#{n}"}
    cnpj { Faker::Company.unique.brazilian_company_number }
    sequence(:phone) {|n| "429999-999#{n}"}
    user
  end
end
