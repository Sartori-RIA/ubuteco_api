# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::WinesController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @wines = create_list(:wine, 10, organization: @organization)
    @makers = create_list(:maker, 5, organization: @organization)
    @wine_styles = create_list(:wine_style, 5)
  end

  path '/api/v1/wines' do
    get 'All Wines' do
      tags 'Wines'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/wines'
        run_test!
      end
    end
    post 'Create a Wine' do
      tags 'Wines'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_wine' }
      response 201, 'Created' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:wine).merge(maker_id: @makers.sample.id, wine_style_id: @wine_styles.sample.id) }
        schema '$ref' => '#/components/schemas/wine'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { {} }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/wines/{id}' do
    get 'Show Wine' do
      tags 'Wines'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @wines.sample.id }
        schema '$ref' => '#/components/schemas/wine'
        run_test!
      end
    end
    put 'Update a Wine' do
      tags 'Wines'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/wine' }
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:wine) }
        let(:id) { @wines.sample.id }
        schema '$ref' => '#/components/schemas/wine'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @wines.sample.id }
        let(:params) { { name: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Wine' do
      tags 'Wines'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @wines.sample.id }
        run_test!
      end
    end
  end
  path '/api/v1/wines/search' do
    get 'Search Wine by name' do
      tags 'Wines'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:q) { 'tralala' }
        schema '$ref' => '#/components/schemas/wines'
        run_test!
      end
    end
  end
end
