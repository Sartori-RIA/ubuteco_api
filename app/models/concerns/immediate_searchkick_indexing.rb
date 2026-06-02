# frozen_string_literal: true

# Ensures newly created catalog records are searchable immediately (async
# Searchkick callbacks may lag behind, especially when Sidekiq is idle).
module ImmediateSearchkickIndexing
  extend ActiveSupport::Concern

  included do
    after_create_commit :reindex_for_immediate_search, unless: -> { Rails.env.test? }
  end

  private

  def reindex_for_immediate_search
    return unless respond_to?(:reindex)

    reindex(refresh: true)
  end
end
