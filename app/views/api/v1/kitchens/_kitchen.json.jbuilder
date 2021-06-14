# frozen_string_literal: true

json.extract! kitchen,
              :id,
              :status,
              :created_at,
              :updated_at

json.table kitchen.order.table if kitchen.order&.table&.present?
json.order_item kitchen.item if kitchen.item.present?
