# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::FoodsController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @foods = create_list(:food, 10, organization: @organization)
  end

  path '/api/v1/foods' do
    get 'All Foods' do
      tags 'Foods'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/foods'
        run_test!
      end
    end
    post 'Create a Food' do
      tags 'Foods'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_food' }
      response 201, 'Created' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:food) }
        schema '$ref' => '#/components/schemas/food'
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

  path '/api/v1/foods/{id}' do
    get 'Show Food' do
      tags 'Foods'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response '200', 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @foods.sample.id }
        schema '$ref' => '#/components/schemas/food'
        run_test!
      end
    end
    put 'Update a Food' do
      tags 'Foods'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/food' }
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @foods.sample.id }
        let(:params) { attributes_for(:food) }
        schema '$ref' => '#/components/schemas/food'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { { name: nil } }
        let(:id) { @foods.sample.id }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Food' do
      tags 'Foods'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @foods.sample.id }
        run_test!
      end
    end
  end
end
