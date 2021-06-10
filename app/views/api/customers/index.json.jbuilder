# frozen_string_literal: true

json.array! @customers, partial: 'api/customers/customer', as: :customer
