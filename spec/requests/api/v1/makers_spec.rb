require 'swagger_helper'

RSpec.describe '/api/v1/makers', type: :request do
  path '/api/v1/makers' do
    get 'All Makers' do
      tags 'Makers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Maker' do
      tags 'Makers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/makers/search' do
    get 'Search Maker by name' do
      tags 'Makers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/makers/{id}' do
    get 'Show Maker' do
      tags 'Makers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Maker' do
      tags 'Makers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Maker' do
      tags 'Makers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
