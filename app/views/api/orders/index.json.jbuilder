# frozen_string_literal: true

json.array! @orders, partial: 'api/orders/order', as: :order
