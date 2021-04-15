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
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
    post 'Create a Maker' do
      tags 'Makers'
      security [Bearer: {}]
      response 201, 'Created' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
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
  path '/api/v1/makers/{id}' do
    get 'Show Maker' do
      tags 'Makers'
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
    put 'Update a Maker' do
      tags 'Makers'
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
    delete 'Destroy a Maker' do
      tags 'Makers'
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
  path '/api/v1/makers/search' do
    get 'Search Maker by name' do
      tags 'Makers'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
  end
end
