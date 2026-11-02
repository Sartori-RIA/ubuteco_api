# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::RestockSuggestionsQuery do
  let(:organization) { create(:organization, timezone: 'America/Sao_Paulo') }
  let(:zone) { Time.find_zone!('America/Sao_Paulo') }
  let!(:order_item) do
    create(:order_item, order: create(:order, organization:), item: create(:dish, organization:))
  end

  around do |example|
    travel_to(zone.local(2026, 11, 2, 10, 0)) { example.run }
  end

  def sell(product, at:, units: 2)
    StockMovement.create!(
      organization:,
      product:,
      delta: -units,
      order_item:,
      created_at: at
    )
  end

  def suggestions
    described_class.call(organization:)[:items]
  end

  it 'suggests a quantity from steady sales and ignores manual adjustments' do
    beer = create(:beer, organization:, name: 'Steady', quantity_stock: 2)
    7.times { |offset| sell(beer, at: zone.local(2026, 11, 2, 12, 0) - offset.days) }
    StockMovement.create!(
      organization:, product: beer, delta: -40, reason: 'waste', created_at: zone.local(2026, 11, 1, 12, 0)
    )

    item = suggestions.find { |row| row[:name] == 'Steady' }

    expect(item).to include(
      product_type: 'beers',
      avg_daily: 0.5,
      days_of_cover: 4.0,
      suggested_quantity: 2,
      confidence: 'ok',
      quantity_stock: 2
    )
  end

  it 'flags products with fewer than 7 sale days and products with no history' do
    short = create(:beer, organization:, name: 'Short', quantity_stock: 8)
    create(:wine, organization:, name: 'Quiet', quantity_stock: 3)
    3.times { |offset| sell(short, at: zone.local(2026, 11, 2, 12, 0) - offset.days) }

    rows = suggestions.index_by { |row| row[:name] }

    expect(rows['Short']).to include(confidence: 'low', suggested_quantity: nil)
    expect(rows['Quiet']).to include(confidence: 'low', avg_daily: 0.0, days_of_cover: nil, suggested_quantity: nil)
  end

  it 'drops soft-deleted products and keeps the org timezone boundary' do
    inside = create(:beer, organization:, name: 'Inside edge', quantity_stock: 1)
    outside = create(:beer, organization:, name: 'Outside edge', quantity_stock: 1)
    gone = create(:food, organization:, name: 'Gone', quantity_stock: 1)
    sell(inside, at: zone.local(2026, 10, 6, 0, 30))
    sell(outside, at: zone.local(2026, 10, 5, 23, 30))
    sell(gone, at: zone.local(2026, 11, 1, 12, 0))
    gone.destroy

    rows = suggestions.index_by { |row| row[:name] }

    expect(rows['Inside edge'][:avg_daily]).to eq(0.07)
    expect(rows['Outside edge'][:avg_daily]).to eq(0.0)
    expect(rows).not_to have_key('Gone')
  end

  it 'sorts products that run out sooner first' do
    soon = create(:drink, organization:, name: 'Soon', quantity_stock: 1)
    later = create(:food, organization:, name: 'Later', quantity_stock: 20)
    7.times { |offset| sell(soon, at: zone.local(2026, 11, 2, 12, 0) - offset.days, units: 4) }
    7.times { |offset| sell(later, at: zone.local(2026, 11, 2, 12, 0) - offset.days, units: 1) }

    names = suggestions.select { |row| row[:confidence] == 'ok' }.pluck(:name)

    expect(names).to eq(%w[Soon Later])
  end

  it 'rejects a cover window outside the allowed range' do
    expect { described_class.call(organization:, cover_days: 0) }.to raise_error(ArgumentError)
    expect { described_class.call(organization:, window_days: 6) }.to raise_error(ArgumentError)
  end
end
