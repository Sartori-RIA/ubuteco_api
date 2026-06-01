# frozen_string_literal: true

json.extract! organization,
              :id,
              :name,
              :phone,
              :user_id,
              :operational_status,
              :locale,
              :default_currency,
              :timezone,
              :logo_url,
              :created_at,
              :updated_at
