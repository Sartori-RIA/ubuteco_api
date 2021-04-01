require 'swagger_helper'

RSpec.describe '/api/v1/wines', type: :request do
  path '/api/v1/wines' do
    get 'All Wines' do
      tags 'Wines'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Wine' do
      tags 'Wines'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/wines/search' do
    get 'Search Wine by name' do
      tags 'Wines'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/wines/{id}' do
    get 'Show Wine' do
      tags 'Wines'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Wine' do
      tags 'Wines'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Wine' do
      tags 'Wines'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
