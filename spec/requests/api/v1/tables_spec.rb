require 'swagger_helper'

RSpec.describe '/api/v1/tables', type: :request do
  path '/api/v1/tables' do
    get 'All Tables' do
      tags 'Tables'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Table' do
      tags 'Tables'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/tables/search' do
    get 'Search Table by name' do
      tags 'Tables'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/tables/{id}' do
    get 'Show Table' do
      tags 'Tables'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Table' do
      tags 'Tables'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Table' do
      tags 'Tables'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
