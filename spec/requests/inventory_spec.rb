# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Inventory API', type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }
  let(:cash_register) { create(:user, :cash_register, organization: organization) }
  let(:waiter) { create(:user, :waiter, organization: organization) }

  describe 'PATCH /api/v1/beers/:id/stock' do
    let!(:beer) { create(:beer, organization: organization, quantity_stock: 10) }

    it 'adjusts stock for admin' do
      patch "/api/v1/beers/#{beer.id}/stock",
            params: { adjustment: 5, reason: 'delivery' },
            headers: auth_header(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['quantity_stock']).to eq(15)
      expect(beer.reload.quantity_stock).to eq(15)
    end

    it 'allows cash register to adjust stock' do
      patch "/api/v1/beers/#{beer.id}/stock",
            params: { adjustment: -2 },
            headers: auth_header(cash_register),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(beer.reload.quantity_stock).to eq(8)
    end

    it 'forbids waiter from adjusting stock' do
      patch "/api/v1/beers/#{beer.id}/stock",
            params: { adjustment: 1 },
            headers: auth_header(waiter),
            as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it 'returns validation errors when stock would go negative' do
      patch "/api/v1/beers/#{beer.id}/stock",
            params: { adjustment: -20 },
            headers: auth_header(admin),
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      errors = response.parsed_body['errors']
      expect(errors).to be_present
      expect(errors.first['code']).to eq('insufficient_stock')
      expect(beer.reload.quantity_stock).to eq(10)
    end

    it 'stores reason on manual adjustment' do
      patch "/api/v1/beers/#{beer.id}/stock",
            params: { adjustment: 3, reason: 'delivery' },
            headers: auth_header(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      movement = StockMovement.find_by!(product: beer, user: admin)
      expect(movement.delta).to eq(3)
      expect(movement.reason).to eq('delivery')
    end
  end

  describe 'GET /api/v1/inventory/low_stock' do
    before do
      create(:beer, organization: organization, name: 'Low Beer', quantity_stock: 2)
      create(:wine, organization: organization, name: 'Ok Wine', quantity_stock: 20)
      create(:drink, organization: organization, name: 'Low Drink', quantity_stock: 0)
    end

    it 'lists low stock items for admin' do
      get '/api/v1/inventory/low_stock', headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['threshold']).to eq(5)
      names = body['items'].pluck('name')
      expect(names).to contain_exactly('Low Beer', 'Low Drink')
    end

    it 'forbids waiter from reading low stock' do
      get '/api/v1/inventory/low_stock', headers: auth_header(waiter)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
