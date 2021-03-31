require 'swagger_helper'

RSpec.describe 'api/v1/organizations/{organization_id}/themes', type: :request do
  path 'api/v1/organizations/{organization_id}/themes' do
    get 'All Wine Styles' do
      tags 'All Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    get 'Show Wine Style' do
      tags 'Find Wine Style'
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
