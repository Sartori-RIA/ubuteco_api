require 'swagger_helper'

RSpec.describe '/api/v1/organizations', type: :request do
  path '/api/v1/organizations' do
    get 'All Organizations' do
      tags 'Organizations'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Organization' do
      tags 'Organizations'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/organizations/search' do
    get 'Search Organization by name and cnpj' do
      tags 'Organizations'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/organizations/{id}' do
    get 'Show Organization' do
      tags 'Organizations'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Organization' do
      tags 'Organizations'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Organization' do
      tags 'Organizations'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
