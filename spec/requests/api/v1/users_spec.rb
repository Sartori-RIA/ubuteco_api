require 'swagger_helper'

RSpec.describe '/api/v1/users', type: :request do
  path '/api/v1/users' do
    get 'All Users' do
      tags 'Users'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a User' do
      tags 'Users'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/users/search' do
    get 'Search User by name or email' do
      tags 'Users'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/users/{id}' do
    get 'Show User' do
      tags 'Users'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a User' do
      tags 'Users'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a User' do
      tags 'Users'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
