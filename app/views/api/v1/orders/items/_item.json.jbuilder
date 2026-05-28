# frozen_string_literal: true

json.extract! item,
              :id,
              :order_id,
              :quantity,
              :item_type,
              :item_id,
              :status,
              :created_at,
              :updated_at

if item.item.present?
  json.item do
    json.extract! item.item, :id, :name, :price_cents, :price_currency
    json.quantity_stock item.item.quantity_stock if item.item.respond_to?(:quantity_stock)
  end
end
