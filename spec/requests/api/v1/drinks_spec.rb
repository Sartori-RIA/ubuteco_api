# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::DrinksController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @drinks = create_list(:drink, 10, organization: @organization)
  end

  path '/api/v1/drinks' do
    get 'All Drinks' do
      tags 'Drinks'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/drinks'
        run_test!
      end
    end
    post 'Create a Drink' do
      tags 'Drinks'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_drink' }
      response 201, 'Created' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:drink) }
        schema '$ref' => '#/components/schemas/drink'
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
  path '/api/v1/drinks/{id}' do
    get 'Show Drink' do
      tags 'Drinks'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @drinks.sample.id }
        schema '$ref' => '#/components/schemas/drink'
        run_test!
      end
    end
    put 'Update a Drink' do
      tags 'Drinks'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/drink' }
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:drink) }
        let(:id) { @drinks.sample.id }
        schema '$ref' => '#/components/schemas/drink'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @drinks.sample.id }
        let(:params) { { name: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Drink' do
      tags 'Drinks'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @drinks.sample.id }
        run_test!
      end
    end
  end
end
