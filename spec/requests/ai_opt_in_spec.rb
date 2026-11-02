# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organization AI opt-in', type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }

  it 'lets an admin turn AI on and returns the flag' do
    patch api_v1_organization_path(organization),
          params: { ai_enabled: true }.to_json,
          headers: auth_header(admin)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['ai_enabled']).to be(true)
    expect(organization.reload.ai_enabled).to be(true)
  end

  it 'does not let a waiter turn AI on' do
    waiter = create(:user, :waiter, organization:)

    patch api_v1_organization_path(organization),
          params: { ai_enabled: true }.to_json,
          headers: auth_header(waiter)

    expect(response).to have_http_status(:ok)
    expect(organization.reload.ai_enabled).to be(false)
  end
end
