# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Product intake API', type: :request do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:admin) { organization.user }
  let(:waiter) { create(:user, :waiter, organization:) }
  let(:xml) { Rails.root.join('spec/fixtures/files/nfe_sample.xml') }
  let(:png_path) { Rails.root.join('spec/fixtures/files/label.png') }

  before do
    File.binwrite(png_path, Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='))
  end

  def post_file(path, file, type, user: admin, extra: {})
    headers = auth_header(user)
    headers.delete('Content-Type')
    post path, params: extra.merge(file: Rack::Test::UploadedFile.new(file, type)), headers:
  end

  it 'parses an NF-e without creating products' do
    create(:beer, organization:, name: 'Cerveja Lager')
    before_count = Beer.count

    post_file '/api/v1/inventory/intake/nfe', xml, 'application/xml'

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body['lines'].first['match']).to include('confidence' => 'high')
    expect(body['lines'].second['match']).to be_nil
    expect(body['lines'].second['quantity']).to eq(1.5)
    expect(Beer.count).to eq(before_count)
  end

  it 'rejects a file that is not an NF-e' do
    broken = Rails.root.join('tmp/not-nfe.xml')
    File.write(broken, '<nope/>')

    post_file '/api/v1/inventory/intake/nfe', broken, 'application/xml'

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body['errors'].first['code']).to eq('invalid_document')
  end

  it 'forbids a waiter' do
    post_file '/api/v1/inventory/intake/nfe', xml, 'application/xml', user: waiter

    expect(response).to have_http_status(:forbidden)
  end

  it 'fills a beer draft from a label photo and does not save it' do
    ENV['AI_ENABLED'] = '1'
    Ai::FakeClient.enqueue(
      Ai.result(text: '{"name":"Loba IPA","maker":null,"style":null,"abv":6.5,"ibu":40,"description":"Citrica"}')
    )

    expect do
      post_file '/api/v1/catalog/intake/label', png_path, 'image/png', extra: { product_type: 'beer' }
    end.not_to change(Beer, :count)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['draft']['name']).to eq('Loba IPA')
  ensure
    ENV.delete('AI_ENABLED')
  end

  it 'returns ai_invalid_output when the model reply is not JSON' do
    ENV['AI_ENABLED'] = '1'
    Ai::FakeClient.enqueue(Ai.result(text: 'hello'))

    post_file '/api/v1/catalog/intake/label', png_path, 'image/png', extra: { product_type: 'beer' }

    expect(response).to have_http_status(:bad_gateway)
    expect(response.parsed_body['errors'].first['code']).to eq('ai_invalid_output')
  ensure
    ENV.delete('AI_ENABLED')
  end

  it 'reads an invoice photo into matched lines' do
    ENV['AI_ENABLED'] = '1'
    Ai::FakeClient.enqueue(
      Ai.result(text: '[{"description":"Cerveja Lager","ean":null,"quantity":4,"unit":"UN","unit_cost_cents":800}]')
    )
    create(:beer, organization:, name: 'Cerveja Lager')

    post_file '/api/v1/inventory/intake/document', png_path, 'image/png'

    expect(response).to have_http_status(:ok)
    line = response.parsed_body['lines'].first
    expect(line['source']).to eq('ai')
    expect(line['match']['confidence']).to eq('high')
  ensure
    ENV.delete('AI_ENABLED')
  end
end
