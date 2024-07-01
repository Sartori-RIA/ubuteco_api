# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::OrganizationsController, type: :request do
  before do
    @organization = create(:organization)
    @admin = @organization.user
  end

  path '/api/v1/organizations' do
    get 'All Organizations' do
      tags 'Organizations'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/organizations'
        run_test!
      end
    end
  end
  path '/api/v1/organizations/{id}' do
    get 'Show Organization' do
      tags 'Organizations'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @organization.id }
        schema '$ref' => '#/components/schemas/organization'
        run_test!
      end
    end
    put 'Update a Organization' do
      tags 'Organizations'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/organization' }
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @organization.id }
        let(:params) { attributes_for(:organization) }
        schema '$ref' => '#/components/schemas/organization'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @organization.id }
        let(:params) { { name: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Organization' do
      tags 'Organizations'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:id) { @organization.id }
        run_test!
      end
    end
  end
  path '/api/v1/organizations/search' do
    get 'Search Organization by name' do
      tags 'Organizations'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Ok' do
        let(:Authorization) { auth_header(@admin)['Authorization'] }
        let(:q) { 'tralala' }
        schema '$ref' => '#/components/schemas/organizations'
        run_test!
      end
    end
  end
end
