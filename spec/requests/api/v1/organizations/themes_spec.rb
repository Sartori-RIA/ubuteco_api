require 'swagger_helper'

RSpec.describe Api::V1::Organizations::ThemesController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { organization.user }
  path '/api/v1/organizations/{organization_id}/themes' do
    get 'Show organization theme' do
      tags 'Organization Theme'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :organization_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(user)['Authorization'] }
        let(:organization_id) { organization.id }
        schema '$ref' => '#/components/schemas/themes'
        run_test!
      end
    end
  end
  path '/api/v1/organizations/{organization_id}/themes/{theme_id}' do
    get 'Show organization theme' do
      tags 'Organization Theme'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :organization_id, in: :path, type: :string
      parameter name: :theme_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(user)['Authorization'] }
        let(:organization_id) { organization.id }
        let(:theme_id) { organization.theme.id }
        schema '$ref' => '#/components/schemas/theme'
        run_test!
      end
    end
    put 'Update organization theme' do
      tags 'Organization Theme'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :organization_id, in: :path, type: :string
      parameter name: :theme_id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/theme' }
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(user)['Authorization'] }
        let(:organization_id) { organization.id }
        let(:theme_id) { organization.theme.id }
        let(:params) { attributes_for(:theme) }
        schema '$ref' => '#/components/schemas/theme'
        run_test!
      end
      response '422', 'Invalid request' do
        let(:'Authorization') { auth_header(user)['Authorization'] }
        let(:organization_id) { organization.id }
        let(:theme_id) { organization.theme.id }
        let(:params) { { color_sidebar: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
end
