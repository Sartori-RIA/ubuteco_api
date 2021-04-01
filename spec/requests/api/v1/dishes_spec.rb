require 'swagger_helper'

RSpec.describe '/api/v1/dishes', type: :request do
  path '/api/v1/dishes' do
    get 'All Dishes' do
      tags 'Dishes'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Dish' do
      tags 'Dishes'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/dishes/search' do
    get 'Search dish by name' do
      tags 'Dishes'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/dishes/{id}' do
    get 'Show Dish' do
      tags 'Dishes'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Dish' do
      tags 'Dishes'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Dish' do
      tags 'Dishes'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
