require 'swagger_helper'

RSpec.describe 'api/v1/kitchens', type: :request do
  path '/api/v1/wine_styles' do
    get 'All Wine Styles' do
      tags 'All Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Wine Style' do
      tags 'Update Wine Style'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
