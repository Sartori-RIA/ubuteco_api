# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::MakersController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @makers = create_list(:maker, 10, organization: @organization)
  end

  path '/api/v1/makers' do
    get 'All Makers' do
      tags 'Makers'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/makers'
        run_test!
      end
    end
    post 'Create a Maker' do
      tags 'Makers'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_maker' }
      response 201, 'Created' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:maker) }
        schema '$ref' => '#/components/schemas/maker'
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
  path '/api/v1/makers/{id}' do
    get 'Show Maker' do
      tags 'Makers'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @makers.sample.id }
        schema '$ref' => '#/components/schemas/maker'
        run_test!
      end
    end
    put 'Update a Maker' do
      tags 'Makers'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/maker' }
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:maker) }
        let(:id) { @makers.sample.id }
        schema '$ref' => '#/components/schemas/maker'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @makers.sample.id }
        let(:params) { { name: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Maker' do
      tags 'Makers'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @makers.sample.id }
        run_test!
      end
    end
  end
end
