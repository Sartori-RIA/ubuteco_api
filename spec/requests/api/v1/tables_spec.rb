require 'swagger_helper'

RSpec.describe Api::V1::TablesController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @tables = create_list(:table, 10, organization: @organization)
  end

  path '/api/v1/tables' do
    get 'All Tables' do
      tags 'Tables'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
    post 'Create a Table' do
      tags 'Tables'
      security [Bearer: {}]
      response 200, 'Ok' do
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
  path '/api/v1/tables/{id}' do
    get 'Show Table' do
      tags 'Tables'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
      response 404, 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    put 'Update a Table' do
      tags 'Tables'
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
    delete 'Destroy a Table' do
      tags 'Tables'
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
  path '/api/v1/tables/search' do
    get 'Search Table by name' do
      tags 'Tables'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
  end
end
