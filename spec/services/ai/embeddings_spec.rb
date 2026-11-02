# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::Embeddings do
  let(:organization) { create(:organization, ai_enabled: true) }

  around do |example|
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'returns a deterministic vector for the same text' do
    first = described_class.embed(['witbier'], organization:).first
    second = described_class.embed(['witbier'], organization:).first

    expect(first.length).to eq(described_class::DIMENSIONS)
    expect(first).to eq(second)
    expect(first).not_to eq(described_class.embed(['stout'], organization:).first)
  end

  it 'records a usage row' do
    expect { described_class.embed(['witbier'], organization:) }
      .to change { AiUsageEvent.where(feature: 'menu_search', status: 'ok').count }.by(1)
  end

  it 'refuses an organization that has not opted in' do
    organization.update!(ai_enabled: false)

    expect { described_class.embed(['witbier'], organization:) }.to raise_error(Ai::DisabledError)
  end

  it 'requires an organization' do
    expect { described_class.embed(['witbier'], organization: nil) }.to raise_error(ArgumentError)
  end
end
