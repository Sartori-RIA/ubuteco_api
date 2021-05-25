json.extract! kitchen,
              :id,
              :status,
              :created_at,
              :updated_at

json.table kitchen.order.table
json.order_item kitchen.item
