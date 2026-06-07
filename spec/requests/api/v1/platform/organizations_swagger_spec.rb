# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::Platform::OrganizationsController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:super_admin) { create(:user, :super_admin, organization: nil) }
  let!(:admin) { organization.user }

  path '/api/v1/platform/organizations' do
    get 'List organizations (platform)' do
      tags 'Platform'
      security [Bearer: {}]
      produces 'application/json'

      response '200', 'Ok' do
        let(:Authorization) { auth_header(super_admin)['Authorization'] }

        run_test!
      end

      response '403', 'Forbidden' do
        let(:Authorization) { auth_header(admin)['Authorization'] }

        run_test!
      end
    end
  end

  path '/api/v1/platform/organizations/{id}' do
    get 'Show organization (platform)' do
      tags 'Platform'
      security [Bearer: {}]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'Ok' do
        let(:Authorization) { auth_header(super_admin)['Authorization'] }
        let(:id) { organization.id }

        run_test!
      end
    end
  end

  path '/api/v1/platform/organizations/{organization_id}/users' do
    get 'List organization users (platform)' do
      tags 'Platform'
      security [Bearer: {}]
      produces 'application/json'
      parameter name: :organization_id, in: :path, type: :string

      response '200', 'Ok' do
        let(:Authorization) { auth_header(super_admin)['Authorization'] }
        let(:organization_id) { organization.id }

        run_test!
      end
    end
  end
end
