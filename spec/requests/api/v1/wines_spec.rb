require 'swagger_helper'

RSpec.describe Api::V1::WinesController, type: :request do
  path '/api/v1/wines' do
    get 'All Wines' do
      tags 'All Wines'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    get 'Show Wine' do
      tags 'Find Wine'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Wine' do
      tags 'Create Wine'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Wine' do
      tags 'Update Wine'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Wine' do
      tags 'Destroy Wine'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/wines/search' do
    get 'Search Wines' do
      tags 'Search Wines'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
