# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbedProductJob, type: :job do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:other) { create(:organization, ai_enabled: true) }
  let(:beer) { create(:beer, organization:) }

  around do |example|
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'uses the ai queue' do
    expect(described_class.get_sidekiq_options['queue']).to eq(:ai)
  end

  it 'stores a vector and does not embed the same text again' do
    allow(beer).to receive(:reindex)
    allow(Beer).to receive(:find_by).and_return(beer)

    described_class.new.perform('Beer', beer.id, organization.id)

    expect(beer.reload.embedding.length).to eq(Ai::Embeddings::DIMENSIONS)
    expect(beer.embedding_digest).to eq(Catalog::EmbeddingText.digest(beer))
    expect(Current.organization).to be_nil

    expect(Ai::Embeddings).not_to receive(:embed)
    described_class.new.perform('Beer', beer.id, organization.id)
  end

  it 'does not write a product from another organization' do
    foreign = create(:beer, organization: other)

    described_class.new.perform('Beer', foreign.id, organization.id)

    expect(foreign.reload.embedding).to be_nil
    expect(Current.organization).to be_nil
  end

  it 'enqueues when the embedded text changes and skips a price change' do
    beer.update_columns(embedding_digest: Catalog::EmbeddingText.digest(beer))
    EmbedProductJob.jobs.clear

    beer.update!(price: 22)

    expect(EmbedProductJob.jobs).to be_empty

    beer.update!(name: "New #{beer.name}")

    expect(EmbedProductJob.jobs.map { |job| job['args'] }).to include(['Beer', beer.id, organization.id])
  end
end
