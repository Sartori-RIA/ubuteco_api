require 'swagger_helper'

RSpec.describe 'api/v1/wine_styles', type: :request do
  path '/api/v1/wine_styles' do
    get 'All Wine Styles' do
      tags 'Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Wine Style' do
      tags 'Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/wine_styles/{id}' do
    get 'Show Wine Style' do
      tags 'Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Wine Style' do
      tags 'Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Wine Style' do
      tags 'Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/wine_styles/check/style' do
    get 'Check available name' do
      tags 'Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
