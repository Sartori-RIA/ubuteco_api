# frozen_string_literal: true

json.array! @orders, partial: 'api/v1/orders/order', as: :order
