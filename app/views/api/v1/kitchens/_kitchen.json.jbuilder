# frozen_string_literal: true

json.extract! kitchen,
              :id,
              :status,
              :order_id,
              :quantity,
              :item_type,
              :created_at,
              :updated_at
json.table kitchen.order.table if kitchen.order&.table.present?
json.order_item kitchen.item if kitchen.item.present?
