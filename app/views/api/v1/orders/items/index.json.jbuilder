# frozen_string_literal: true

json.array! @items, partial: 'api/v1/orders/items/item', as: :item
