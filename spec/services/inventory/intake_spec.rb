# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::Intake::NfeXmlParser do
  let(:xml) { Rails.root.join('spec/fixtures/files/nfe_sample.xml').read }

  it 'reads lines from an NF-e' do
    lines = described_class.call(xml)

    expect(lines.first).to include(
      description: 'Cerveja Lager',
      ean: nil,
      quantity: 12,
      unit: 'UN',
      unit_cost_cents: 850,
      source: 'xml'
    )
    expect(lines.second).to include(description: 'Vinho Tinto', ean: '7891234567890', quantity: 1.5, unit_cost_cents: 3990)
  end

  it 'rejects a file that is not an NF-e' do
    xml = Rails.root.join('spec/fixtures/files/nfe_malformed.xml').read

    expect { described_class.call(xml) }.to raise_error(described_class::Invalid)
  end
end

RSpec.describe Inventory::Intake::Matcher do
  let(:organization) { create(:organization) }
  let(:other) { create(:organization) }

  it 'matches a name in the same organization and ignores another tenant' do
    mine = create(:beer, organization:, name: 'Cerveja Lager')
    create(:beer, organization: other, name: 'Cerveja Lager')

    lines = described_class.call(
      organization:,
      lines: [{ description: 'cerveja lager' }, { description: 'Produto novo' }]
    )

    expect(lines.first[:match]).to include(product_type: 'beers', id: mine.id, confidence: 'high')
    expect(lines.second[:match]).to be_nil
  end

  it 'marks a partial name match as low confidence' do
    beer = create(:beer, organization:, name: 'Cerveja Lager 600ml')

    lines = described_class.call(organization:, lines: [{ description: 'Lager' }])

    expect(lines.first[:match]).to include(id: beer.id, confidence: 'low')
  end
end
