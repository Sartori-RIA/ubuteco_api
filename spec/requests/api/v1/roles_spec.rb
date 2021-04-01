require 'swagger_helper'

RSpec.describe '/api/v1/roles', type: :request do
  path '/api/v1/roles' do
    get 'All Roles' do
      tags 'Roles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Role' do
      tags 'Roles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/roles/{id}' do
    get 'Show Role' do
      tags 'Roles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Role' do
      tags 'Roles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Role' do
      tags 'Roles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
