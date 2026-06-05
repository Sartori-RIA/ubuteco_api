# frozen_string_literal: true

Searchkick.queue_name = :searchkick

if ENV["SEARCHKICK_INDEX_PREFIX"].present?
  Searchkick.index_prefix = ENV.fetch("SEARCHKICK_INDEX_PREFIX")
end
