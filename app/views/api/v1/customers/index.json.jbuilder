# frozen_string_literal: true

json.array! @customers, partial: 'api/v1/customers/customer', as: :customer
