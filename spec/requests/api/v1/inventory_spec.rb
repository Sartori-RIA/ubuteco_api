# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::InventoryController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:beer) { create(:beer, organization: organization, quantity_stock: 10) }

  path '/api/v1/inventory/low_stock' do
    get 'Low stock inventory' do
      tags 'Inventory'
      security [Bearer: {}]
      produces 'application/json'

      response '200', 'Ok' do
        let(:Authorization) { auth_header(admin)['Authorization'] }

        before do
          create(:beer, organization: organization, name: 'Low Beer', quantity_stock: 2)
        end

        run_test!
      end
    end
  end

  path '/api/v1/beers/{id}/stock' do
    patch 'Adjust beer stock' do
      tags 'Inventory'
      security [Bearer: {}]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          adjustment: { type: :integer },
          reason: { type: :string }
        },
        required: %w[adjustment]
      }

      response '200', 'Ok' do
        let(:Authorization) { auth_header(admin)['Authorization'] }
        let(:id) { beer.id }
        let(:params) { { adjustment: 5, reason: 'delivery' } }

        schema '$ref' => '#/components/schemas/beer'

        run_test!
      end

      response '422', 'Invalid request' do
        let(:Authorization) { auth_header(admin)['Authorization'] }
        let(:id) { beer.id }
        let(:params) { { adjustment: -20 } }

        schema '$ref' => '#/components/schemas/errors_response'

        run_test!
      end
    end
  end
end
