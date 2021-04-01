require 'swagger_helper'

RSpec.describe '/api/v1/drinks', type: :request do
  path '/api/v1/drinks' do
    get 'All Drinks' do
      tags 'Drinks'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Drink' do
      tags 'Drinks'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/drinks/search' do
    get 'Search Drink by name' do
      tags 'Drinks'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/drinks/{id}' do
    get 'Show Drink' do
      tags 'Drinks'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Drink' do
      tags 'Drinks'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Drink' do
      tags 'Drinks'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
