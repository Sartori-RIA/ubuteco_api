require 'swagger_helper'

RSpec.describe Api::V1::BeerStylesController, type: :request do

  before :all do
    @admin = create(:super_admin)
    @beer_styles = create_list(:beer_style, 10)
  end

  path '/api/v1/beer_styles' do
    get 'All Beer Styles' do
      tags 'Beer Styles'
      response 200, 'Ok' do
        schema '$ref' => '#/components/schemas/beer_styles'
        run_test!
      end
    end
    post 'Create a Beer Style' do
      tags 'Beer Styles'
      security [Bearer: {}]
      parameter in: :body, type: :object,
                schema: {
                  properties: {
                    name: { type: :string }
                  },
                  required: %w[name]
                }
      response 201, 'Created' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string }
               },
               required: %w[id name]
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/beer_styles/{id}' do
    get 'Show Beer Style' do
      tags 'Beer Styles'
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        run_test!
      end
      response 404, 'Not Found' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
    put 'Update a Beer Style' do
      tags 'Beer Styles'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter in: :body, type: :object,
                schema: {
                  properties: {
                    name: { type: :string }
                  },
                  required: %w[name]
                }
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string }
               },
               required: %w[name]
        run_test!
      end
      response 404, 'Not Found' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Beer Style' do
      tags 'Beer Styles'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
      response 404, 'Not Found' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
  end
  path '/api/v1/beer_styles/check/style' do
    get 'Check available name' do
      tags 'Beer Styles'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Already Exists' do
        run_test!
      end
      response 204, 'Name available' do
        run_test!
      end
    end
  end
end
