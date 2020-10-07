FactoryBot.define do
  factory :order do
    total { "9.99" }
    total_with_discount { "9.99" }
    discount { "9.99" }
    table { nil }
    user
  end
end
