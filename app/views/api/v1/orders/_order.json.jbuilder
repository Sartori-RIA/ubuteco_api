# frozen_string_literal: true

json.extract! order,
              :id,
              :total_cents,
              :total_currency,
              :total_with_discount_cents,
              :total_with_discount_currency,
              :discount_cents,
              :discount_currency,
              :table,
              :table_id,
              :organization,
              :organization_id,
              :status,
              :user_id,
              :user,
              :created_at,
              :updated_at

json.order_items_count order.order_items.size
