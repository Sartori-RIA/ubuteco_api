# frozen_string_literal: true

module Catalog
  # Keyword list plus k-NN list, merged with reciprocal rank fusion.
  # Returns nil when the caller should keep the existing keyword search.
  class SemanticSearch
    CANDIDATES = 50
    RRF_K = 60

    def self.call(model:, query:, where:, mode:, organization:)
      new(model:, query:, where:, mode:, organization:).call
    end

    def initialize(model:, query:, where:, mode:, organization:)
      @model = model
      @query = query.to_s
      @where = where
      @mode = mode
      @organization = organization
    end

    def call
      vector = query_vector
      return if vector.nil?

      neighbors = neighbor_ids(vector)
      return if mode == 'semantic' && neighbors.nil?

      load(fuse(lexical_ids, neighbors || []))
    end

    private

    attr_reader :model, :query, :where, :mode, :organization

    def query_vector
      normalized = query.strip.downcase
      return if normalized.blank?

      key = "ai:embed:q:v1:#{organization.id}:#{Digest::SHA256.hexdigest(normalized)}"
      vector = Rails.cache.fetch(key, expires_in: 1.hour) do
        Ai::Embeddings.embed([normalized], organization:).first
      end
      vector if vector.is_a?(Array) && vector.length == Ai::Embeddings::DIMENSIONS
    rescue Ai::Error
      nil
    end

    def lexical_ids
      return [] if mode == 'semantic'

      ids_from(model.search(query, where:, limit: CANDIDATES, load: false))
    end

    def neighbor_ids(vector)
      ids_from(
        model.search(
          '*',
          where:,
          knn: { field: :embedding, vector: },
          limit: CANDIDATES,
          load: false
        )
      )
    rescue Searchkick::Error, Faraday::Error
      nil
    end

    def ids_from(results)
      results.map { |hit| hit.id.to_i }
    end

    def fuse(keyword_ids, vector_ids)
      scores = Hash.new(0.0)
      [keyword_ids, vector_ids].each do |ids|
        ids.each_with_index do |id, rank|
          scores[id] += 1.0 / (RRF_K + rank + 1)
        end
      end
      scores.sort_by { |_id, score| -score }.map(&:first)
    end

    def load(ids)
      return [] if ids.empty?

      scope = model.where(id: ids)
      scope = scope.where(organization_id: where[:organization_id]) if where.key?(:organization_id)
      by_id = scope.index_by(&:id)
      ids.filter_map { |id| by_id[id] }
    end
  end
end
