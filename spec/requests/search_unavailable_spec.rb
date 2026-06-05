# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search unavailable', type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }

  it 'returns search_unavailable when OpenSearch is down' do
    allow(Beer).to receive(:pagy_search).and_raise(Faraday::ConnectionFailed, 'connection refused')

    get api_v1_beers_path, headers: auth_header(admin)

    expect(response).to have_http_status(:service_unavailable)
    expect(response.parsed_body.dig('errors', 0, 'code')).to eq('search_unavailable')
  end
end
