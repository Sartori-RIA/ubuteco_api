require 'swagger_helper'

RSpec.describe '/api/v1/foods', type: :request do
  path '/api/v1/foods' do
    get 'All Foods' do
      tags 'Foods'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Food' do
      tags 'Foods'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/foods/search' do
    get 'Search Food by name' do
      tags 'Foods'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/foods/{id}' do
    get 'Show Food' do
      tags 'Foods'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Food' do
      tags 'Foods'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Food' do
      tags 'Foods'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
