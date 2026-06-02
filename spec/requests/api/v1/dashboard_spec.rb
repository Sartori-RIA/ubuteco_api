# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DashboardController, type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }
  let(:cashier) { create(:user, :cash_register, organization:) }
  let(:waiter) { create(:user, :waiter, organization:) }
  let(:other_org) { create(:organization) }
  let(:from) { 6.days.ago.to_date.iso8601 }
  let(:to) { Date.current.iso8601 }

  describe 'GET /api/v1/dashboard/summary' do
    it 'allows admin to read summary' do
      get '/api/v1/dashboard/summary', params: { from:, to: }, headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        'revenue_cents',
        'orders_count',
        'open_orders_count',
        'average_ticket_cents',
        'currency'
      )
    end

    it 'allows cash register to read summary' do
      get '/api/v1/dashboard/summary', params: { from:, to: }, headers: auth_header(cashier)

      expect(response).to have_http_status(:ok)
    end

    it 'forbids waiter' do
      get '/api/v1/dashboard/summary', params: { from:, to: }, headers: auth_header(waiter)

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects invalid ranges' do
      get '/api/v1/dashboard/summary',
          params: { from: to, to: from },
          headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'GET /api/v1/dashboard/series' do
    it 'returns revenue series for admin' do
      get '/api/v1/dashboard/series',
          params: { from:, to:, metric: 'revenue', grain: 'day' },
          headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['points']).to be_an(Array)
    end
  end
end
