# frozen_string_literal: true

class EmbedProductJob
  include Sidekiq::Job

  sidekiq_options queue: :ai

  def perform(model_name, record_id, organization_id)
    organization = Organization.find_by(id: organization_id)
    return if organization.nil?

    Current.organization = organization
    record = find_record(model_name, record_id, organization.id)
    return if record.nil?

    digest = Catalog::EmbeddingText.digest(record)
    return if record.embedding_digest == digest

    vector = Ai::Embeddings.embed([Catalog::EmbeddingText.for(record)], organization:).first
    return unless vector.is_a?(Array) && vector.length == Ai::Embeddings::DIMENSIONS

    record.update_columns(embedding: vector, embedding_digest: digest) # rubocop:disable Rails/SkipsModelValidations
    record.reindex
  rescue Ai::Error
    nil
  ensure
    Current.reset
  end

  private

  def find_record(model_name, record_id, organization_id)
    model = Catalog::EmbeddingText::MODELS[model_name.to_s]
    return if model.nil?

    model.find_by(id: record_id, organization_id:)
  end
end
