# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::BeersController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @beers = create_list(:beer, 10, organization: @organization)
    @makers = create_list(:maker, 5, organization: @organization)
    @styles = create_list(:beer_style, 5)
  end

  path '/api/v1/beers' do
    get 'All Beers' do
      tags 'Beers'
      security [Bearer: {}]
      parameter name: :q, type: :string
      parameter name: :page, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/beers'
        run_test!
      end
    end
    post 'Create a Beer' do
      tags 'Beers'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_beer' }
      response 201, 'Created' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:beer).merge(maker_id: @makers.sample.id, beer_style_id: @styles.sample.id) }
        schema '$ref' => '#/components/schemas/beer'
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
  path '/api/v1/beers/{id}' do
    get 'Show Beer' do
      tags 'Beers'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @beers.sample.id }
        schema '$ref' => '#/components/schemas/beer'
        run_test!
      end
    end
    put 'Update a Beer' do
      tags 'Beers'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/beer' }
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:beer) }
        let(:id) { @beers.sample.id }
        schema '$ref' => '#/components/schemas/beer'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @beers.sample.id }
        let(:params) { { name: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Beer' do
      tags 'Beers'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @beers.sample.id }
        run_test!
      end
    end
  end
end
