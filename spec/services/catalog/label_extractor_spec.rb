# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::Intake::LabelExtractor do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:user) { organization.user }
  let(:png) { Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==') }

  around do |example|
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'returns a draft and keeps unknown maker and style as text' do
    Ai::FakeClient.enqueue(Ai.result(text: '{"name":"Loba IPA","maker":"Loba","style":"IPA","abv":6.5,"ibu":60,"description":"Amarga","price":12}'))

    payload = nil
    expect do
      payload = described_class.call(
        organization:, user:, bytes: png, media_type: 'image/png', product_type: 'beer'
      )
    end.not_to change(Beer, :count)

    expect(payload[:draft]).to include(name: 'Loba IPA', maker_id: nil, beer_style_id: nil, abv: 6.5, ibu: 60)
    expect(payload[:draft]).not_to have_key(:price)
    expect(payload[:warnings]).to eq(%w[unknown_maker unknown_style])
    expect(payload[:confidence]).to eq('low')
  end

  it 'links a maker and style that already exist' do
    maker = create(:maker, organization:, name: 'Loba')
    style = create(:beer_style, name: 'IPA')
    Ai::FakeClient.enqueue(Ai.result(text: '{"name":"Loba IPA","maker":"loba","style":"ipa","abv":6.5,"ibu":60,"description":""}'))

    payload = described_class.call(
      organization:, user:, bytes: png, media_type: 'image/png', product_type: 'beer'
    )

    expect(payload[:draft]).to include(maker_id: maker.id, beer_style_id: style.id)
    expect(payload[:warnings]).to eq([])
    expect(payload[:confidence]).to eq('high')
  end

  it 'fills a wine draft and leaves a missing abv empty' do
    Ai::FakeClient.enqueue(
      Ai.result(text: '{"name":"Malbec","maker":null,"style":null,"abv":null,"grapes":"Malbec","vintage":2020,"description":""}')
    )

    payload = described_class.call(
      organization:, user:, bytes: png, media_type: 'image/png', product_type: 'wine'
    )

    expect(payload[:draft]).to include(name: 'Malbec', grapes: 'Malbec', vintage_wine: 2020, abv: nil, wine_style_id: nil)
    expect(payload[:confidence]).to eq('high')
  end

  it 'rejects an unknown product type' do
    expect do
      described_class.call(organization:, user:, bytes: png, media_type: 'image/png', product_type: 'food')
    end.to raise_error(ArgumentError, 'unknown product type')
  end

  it 'rejects text that is not the expected JSON' do
    Ai::FakeClient.enqueue(Ai.result(text: 'not json'))

    expect do
      described_class.call(organization:, user:, bytes: png, media_type: 'image/png', product_type: 'beer')
    end.to raise_error(Ai::InvalidOutputError)
  end
end
