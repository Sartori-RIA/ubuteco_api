# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cross-tenant search', type: :request, search: true do
  let(:organization_a) { create(:organization) }
  let(:organization_b) { create(:organization) }
  let(:admin_a) { organization_a.user }

  def record_ids(body)
    Array(body.dig('data')).pluck('id')
  end

  def with_ai
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    yield
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  describe 'catalog search' do
    it 'does not return beers from another organization' do
      unique_name = "CrossTenantBeer#{SecureRandom.hex(4)}"
      beer_b = create(:beer, organization: organization_b, name: unique_name)
      reindex_searchkick!(Beer)

      get api_v1_beers_path, params: { q: unique_name }, headers: auth_header(admin_a)

      expect(response).to have_http_status(:ok)
      expect(record_ids(response.parsed_body)).not_to include(beer_b.id)
    end

    it 'returns beers from the same organization' do
      unique_name = "SameOrgBeer#{SecureRandom.hex(4)}"
      beer_a = create(:beer, organization: organization_a, name: unique_name)
      reindex_searchkick!(Beer)

      get api_v1_beers_path, params: { q: unique_name }, headers: auth_header(admin_a)

      expect(response).to have_http_status(:ok)
      expect(record_ids(response.parsed_body)).to include(beer_a.id)
    end

    it 'keeps semantic results inside the organization' do
      with_ai do
        organization_a.update!(ai_enabled: true)
        query = "citrus#{SecureRandom.hex(2)}"
        beer_a = create(:beer, organization: organization_a, name: "Lagunitas#{SecureRandom.hex(2)}")
        beer_b = create(:beer, organization: organization_b, name: "Outsider#{SecureRandom.hex(2)}")
        vector = Ai::Embeddings::Fake.vector_for(query.downcase)
        beer_a.update_columns(embedding: vector, embedding_digest: 'ready')
        beer_b.update_columns(embedding: vector, embedding_digest: 'ready')
        reindex_searchkick!(Beer)

        get api_v1_beers_path, params: { q: query, mode: 'semantic' }, headers: auth_header(admin_a)

        expect(response).to have_http_status(:ok)
        expect(record_ids(response.parsed_body)).to include(beer_a.id)
        expect(record_ids(response.parsed_body)).not_to include(beer_b.id)

        get api_v1_beers_path, params: { q: query, mode: 'keyword' }, headers: auth_header(admin_a)

        expect(record_ids(response.parsed_body)).not_to include(beer_a.id)

        get api_v1_beers_path, params: { q: query }, headers: auth_header(admin_a)

        expect(record_ids(response.parsed_body)).to include(beer_a.id)
      end
    end

    it 'falls back to keyword search when embeddings fail' do
      with_ai do
        organization_a.update!(ai_enabled: true)
        unique_name = "KeywordOnly#{SecureRandom.hex(2)}"
        beer_a = create(:beer, organization: organization_a, name: unique_name)
        reindex_searchkick!(Beer)
        allow(Ai::Embeddings).to receive(:embed).and_raise(Ai::ProviderError, 'down')

        get api_v1_beers_path, params: { q: unique_name, mode: 'hybrid' }, headers: auth_header(admin_a)

        expect(response).to have_http_status(:ok)
        expect(record_ids(response.parsed_body)).to include(beer_a.id)
      end
    end
  end

  describe 'orders search' do
    let(:waiter_a) { create(:user, :waiter, organization: organization_a) }

    it 'does not return orders from another organization' do
      order_b = create(:order, organization: organization_b)
      reindex_searchkick!(Order)

      get api_v1_orders_path, headers: auth_header(waiter_a)

      expect(response).to have_http_status(:ok)
      expect(record_ids(response.parsed_body)).not_to include(order_b.id)
    end
  end
end
