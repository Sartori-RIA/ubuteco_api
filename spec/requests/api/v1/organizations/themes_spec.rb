require 'swagger_helper'

RSpec.describe '/api/v1/organizations/{organization_id}/themes', type: :request do
  path '/api/v1/organizations/{organization_id}/themes' do
    get 'Show organization theme' do
      tags 'Organization Theme'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/organizations/{organization_id}/themes/{theme_id}' do
    get 'Show organization theme' do
      tags 'Organization Theme'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update organization theme' do
      tags 'Organization Theme'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
