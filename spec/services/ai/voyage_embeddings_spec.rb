# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::Embeddings::Voyage do
  around do |example|
    previous = ENV.fetch('VOYAGE_API_KEY', nil)
    ENV['VOYAGE_API_KEY'] = 'test-key'
    example.run
  ensure
    previous.nil? ? ENV.delete('VOYAGE_API_KEY') : ENV['VOYAGE_API_KEY'] = previous
  end

  it 'returns embeddings in index order' do
    stub_request(:post, Ai::Embeddings::Voyage::URL).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        data: [
          { index: 1, embedding: [0.2] },
          { index: 0, embedding: [0.1] }
        ]
      }.to_json
    )

    expect(described_class.embed(%w[a b])).to eq([[0.1], [0.2]])
  end

  it 'raises when the provider rejects the request' do
    stub_request(:post, Ai::Embeddings::Voyage::URL).to_return(status: 503, body: '')

    expect { described_class.embed(['a']) }.to raise_error(Ai::ProviderError, /voyage 503/)
  end
end
