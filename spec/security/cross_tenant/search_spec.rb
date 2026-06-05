# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cross-tenant search', type: :request, search: true do
  let(:organization_a) { create(:organization) }
  let(:organization_b) { create(:organization) }
  let(:admin_a) { organization_a.user }

  def record_ids(body)
    Array(body.dig('data')).pluck('id')
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
