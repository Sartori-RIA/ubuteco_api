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

  it 'rejects an invoice whose products have no name' do
    xml = <<~XML
      <?xml version="1.0"?>
      <NFe><infNFe>
        <det><prod><xProd>   </xProd><qCom>1</qCom><vUnCom>1</vUnCom></prod></det>
      </infNFe></NFe>
    XML

    expect { described_class.call(xml) }.to raise_error(described_class::Invalid)
  end

  it 'rejects xml that does not parse' do
    expect { described_class.call('<infNFe>') }.to raise_error(described_class::Invalid)
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

  it 'uses a semantic match when the name is not in the catalog text' do
    organization.update!(ai_enabled: true)
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    beer = create(:beer, organization:, name: 'Cerveja Lager')
    allow(Catalog::SemanticSearch).to receive(:call).and_return([beer])

    lines = described_class.call(organization:, lines: [{ description: 'a gelada da casa' }])

    expect(lines.first[:match]).to include(id: beer.id, confidence: 'low')
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'falls back to a partial name when semantic search fails' do
    organization.update!(ai_enabled: true)
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    beer = create(:beer, organization:, name: 'Cerveja Lager 600ml')
    allow(Catalog::SemanticSearch).to receive(:call).and_raise(Searchkick::Error)

    lines = described_class.call(organization:, lines: [{ 'description' => 'Lager' }])

    expect(lines.first[:match]).to include(id: beer.id, confidence: 'low')
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'skips a blank description' do
    lines = described_class.call(organization:, lines: [{ description: '   ' }])

    expect(lines.first[:match]).to be_nil
  end
end

RSpec.describe Inventory::Intake::DocumentExtractor do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:user) { organization.user }

  around do |example|
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  def extract(text, media_type: 'image/png')
    Ai::FakeClient.enqueue(Ai.result(text:))
    described_class.call(organization:, user:, bytes: 'image', media_type:)
  end

  it 'keeps lines that have a description' do
    lines = extract(
      '[{"description":"Cerveja Lager","ean":"","quantity":4,"unit":"UN","unit_cost_cents":800},{"description":"  "}]'
    )

    expect(lines).to eq(
      [{ description: 'Cerveja Lager', ean: nil, quantity: 4, unit: 'UN', unit_cost_cents: 800, source: 'ai' }]
    )
  end

  it 'rejects a reply that is not a list' do
    expect { extract('{"nope":true}') }.to raise_error(Ai::InvalidOutputError)
  end

  it 'rejects a line that is not an object' do
    expect { extract('["nope"]') }.to raise_error(Ai::InvalidOutputError)
  end

  it 'rejects an empty list' do
    expect { extract('[]') }.to raise_error(Ai::InvalidOutputError)
  end

  it 'rejects a quantity or cost that is not a number' do
    expect { extract('[{"description":"A","quantity":"4","unit":"UN","unit_cost_cents":1}]') }
      .to raise_error(Ai::InvalidOutputError)
    Ai::FakeClient.enqueue(Ai.result(text: '[{"description":"A","quantity":1,"unit":"UN","unit_cost_cents":"1"}]'))

    expect do
      described_class.call(organization:, user:, bytes: 'image', media_type: 'image/png')
    end.to raise_error(Ai::InvalidOutputError)
  end

  it 'sends a pdf as a document' do
    allow(Ai::Client).to receive(:complete) do |**kwargs|
      expect(kwargs.dig(:messages, 0, :content, 0, :type)).to eq('document')
      Ai.result(text: '[{"description":"A","quantity":1,"unit":"UN","unit_cost_cents":1}]')
    end

    lines = described_class.call(organization:, user:, bytes: 'pdf', media_type: 'application/pdf')

    expect(lines.first[:description]).to eq('A')
  end
end

RSpec.describe Inventory::Intake::Upload do
  it 'keeps a pdf as-is' do
    bytes = "%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrailer\n<<>>\n%%EOF\n"
    upload = described_class.new(StringIO.new(bytes), allowed: described_class::DOCUMENTS)

    expect(upload.media_type).to eq('application/pdf')
    expect(upload.image_bytes).to eq(bytes)
  end

  it 'rejects a text file when only images are allowed' do
    expect do
      described_class.new(StringIO.new('hello'), allowed: described_class::IMAGES)
    end.to raise_error(described_class::Invalid)
  end

  it 'accepts an NF-e that looks like plain text' do
    allow(Marcel::MimeType).to receive(:for).and_return('text/plain')

    upload = described_class.new(StringIO.new('<NFe><infNFe></infNFe></NFe>'), allowed: described_class::XML)

    expect(upload.media_type).to eq('text/plain')
  end
end
