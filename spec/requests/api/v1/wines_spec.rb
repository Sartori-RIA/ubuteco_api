require 'swagger_helper'

RSpec.describe Api::V1::WinesController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @wines = create_list(:wine, 10, organization: @organization)
  end

  path '/api/v1/wines' do
    get 'All Wines' do
      tags 'Wines'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
    post 'Create a Wine' do
      tags 'Wines'
      security [Bearer: {}]
      response 201, 'Created' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
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
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
      response 404, 'Not Found' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
    put 'Update a Wine' do
      tags 'Wines'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
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
    delete 'Destroy a Wine' do
      tags 'Wines'
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
  path '/api/v1/wines/search' do
    get 'Search Wine by name' do
      tags 'Wines'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
  end
end
