# frozen_string_literal: true

json.array! @items, partial: 'api/orders/items/item', as: :item
