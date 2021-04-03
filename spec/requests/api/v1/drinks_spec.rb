require 'swagger_helper'

RSpec.describe '/api/v1/drinks', type: :request do
  path '/api/v1/drinks' do
    get 'All Drinks' do
      tags 'Drinks'
      security [bearerAuth: []]
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Drink' do
      tags 'Drinks'
      security [bearerAuth: []]
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
  path '/api/v1/drinks/search' do
    get 'Search Drink by name' do
      tags 'Drinks'
      security [bearerAuth: []]
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
  path '/api/v1/drinks/{id}' do
    get 'Show Drink' do
      tags 'Drinks'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    put 'Update a Drink' do
      tags 'Drinks'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    delete 'Destroy a Drink' do
      tags 'Drinks'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
end
