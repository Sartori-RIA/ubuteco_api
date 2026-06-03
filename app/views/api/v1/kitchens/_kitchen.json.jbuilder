# frozen_string_literal: true

json.extract! kitchen,
              :id,
              :order_id,
              :quantity,
              :item_type,
              :created_at,
              :updated_at

json.status kitchen.status
if kitchen.order&.table.present?
  json.table do
    json.extract! kitchen.order.table, :id, :name
  end
end

if kitchen.item.present?
  json.order_item do
    json.extract! kitchen.item, :id, :name, :price_cents, :price_currency
  end
end
