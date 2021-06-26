require 'swagger_helper'

RSpec.describe Api::V1::WineStylesController, type: :request do
  before :all do
    @admin = create(:user, :super_admin)
    @wine_styles = create_list(:wine_style, 10)
  end

  path '/api/v1/wine_styles' do
    get 'All Wine Styles' do
      tags 'Wine Styles'
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/wine_styles'
        run_test!
      end
    end
    post 'Create a Wine Style' do
      tags 'Wine Styles'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_wine_style' }
      response 201, 'Created' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:wine_style) }
        schema '$ref' => '#/components/schemas/wine_style'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { {} }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/wine_styles/{id}' do
    get 'Show Wine Style' do
      tags 'Wine Styles'
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @wine_styles.sample.id }
        schema '$ref' => '#/components/schemas/wine_style'
        run_test!
      end
    end
    put 'Update a Wine Style' do
      tags 'Wine Styles'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/wine_style' }
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:wine_style) }
        let(:id) { @wine_styles.sample.id }
        schema '$ref' => '#/components/schemas/wine_style'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @wine_styles.sample.id }
        let(:params) { { name: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Wine Style' do
      tags 'Wine Styles'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @wine_styles.sample.id }
        run_test!
      end
    end
  end
  path '/api/v1/wine_styles/check/style' do
    get 'Check available name' do
      tags 'Wine Styles'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Already Exists' do
        let(:q) { @wine_styles.sample.name }
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
      response 204, 'Name available' do
        let(:q) { 'tralala' }
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
  end
end
