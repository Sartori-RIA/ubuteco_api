# frozen_string_literal: true

json.array! @tables, partial: 'api/v1/tables/table', as: :table
