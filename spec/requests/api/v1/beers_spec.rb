require 'swagger_helper'

RSpec.describe '/api/v1/beers', type: :request do
  path '/api/v1/beers' do
    get 'All Beers' do
      tags 'Beers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Beer' do
      tags 'Beers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/beers/search' do
    get 'Search beer by name' do
      tags 'Beers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/beers/{id}' do
    get 'Show Beer' do
      tags 'Beers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Beer' do
      tags 'Beers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Beer' do
      tags 'Beers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
