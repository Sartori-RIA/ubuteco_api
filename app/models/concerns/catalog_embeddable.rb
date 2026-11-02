# frozen_string_literal: true

module CatalogEmbeddable
  extend ActiveSupport::Concern

  MODELS = %w[Beer Wine Drink Food Dish].freeze
  KNN = { embedding: { dimensions: Ai::Embeddings::DIMENSIONS, distance: 'cosine' } }.freeze

  included do
    after_commit :enqueue_catalog_embedding, on: %i[create update]
  end

  def embedding_for_index
    vector = Array(embedding)
    return {} unless vector.length == Ai::Embeddings::DIMENSIONS

    { embedding: vector.map(&:to_f) }
  end

  private

  def enqueue_catalog_embedding
    return if embedding_digest == Catalog::EmbeddingText.digest(self)

    EmbedProductJob.perform_async(self.class.name, id, organization_id)
  end
end
