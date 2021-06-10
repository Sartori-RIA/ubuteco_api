# frozen_string_literal: true

json.array! @tables, partial: 'api/tables/table', as: :table
