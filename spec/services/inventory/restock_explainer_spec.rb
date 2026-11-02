# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::RestockExplainer do
  let(:organization) { create(:organization, ai_enabled: true, locale: 'pt-BR') }
  let(:items) do
    [{
      product_type: 'beers',
      id: 4,
      name: 'Pilsen',
      quantity_stock: 4,
      avg_daily: 6,
      days_of_cover: 0.7,
      suggested_quantity: 38,
      confidence: 'ok'
    }]
  end

  around do |example|
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'attaches a sentence that only uses the computed numbers' do
    Ai::FakeClient.enqueue(Ai.result(text: [{ product_type: 'beers', id: 4, explanation: 'Vende 6 por dia e restam 4.' }].to_json))

    explained = described_class.call(organization:, items:, cover_days: 7, window_days: 28)

    expect(explained.first[:explanation]).to eq('Vende 6 por dia e restam 4.')
  end

  it 'drops a sentence that invents a number and survives a provider failure' do
    Ai::FakeClient.enqueue(Ai.result(text: [{ product_type: 'beers', id: 4, explanation: 'Vende 99 por dia.' }].to_json))
    first = described_class.call(organization:, items:, cover_days: 7, window_days: 28)
    expect(first.first).not_to have_key(:explanation)

    Ai::FakeClient.enqueue(Ai::ProviderError.new('down'))
    second = described_class.call(organization:, items:, cover_days: 7, window_days: 28)
    expect(second.first).not_to have_key(:explanation)
  end
end
