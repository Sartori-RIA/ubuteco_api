# frozen_string_literal: true

json.extract! order,
              :id,
              :total,
              :total_with_discount,
              :discount,
              :table,
              :table_id,
              :organization,
              :organization_id,
              :status,
              :user_id,
              :user,
              :created_at,
              :updated_at
