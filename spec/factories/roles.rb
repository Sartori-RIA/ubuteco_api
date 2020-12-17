FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "table name#{n}" }
    factory :admin do
      name { 'ADMIN' }
    end
    factory :super_admin do
      name { 'SUPER_ADMIN' }
    end
    factory :kitchen do
      name { 'KITCHEN' }
    end
    factory :waiter do
      name { 'WAITER' }
    end
    factory :cash_register do
      name { 'CASH_REGISTER' }
    end
    factory :customer do
      name { 'CUSTOMER' }
    end
  end
end

