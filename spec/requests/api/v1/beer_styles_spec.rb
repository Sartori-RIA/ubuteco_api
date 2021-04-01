require 'swagger_helper'

RSpec.describe '/api/v1/beer_styles', type: :request do
  path 'api/v1/beer_styles' do
    get 'All Beer Styles' do
      tags 'Beer Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Beer Style' do
      tags 'Beer Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/beer_styles/check/style' do
    get 'Check available name' do
      tags 'Beer Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path 'api/v1/beer_styles/{id}' do
    get 'Show Beer Style' do
      tags 'Beer Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Beer Style' do
      tags 'Beer Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Beer Style' do
      tags 'Beer Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
