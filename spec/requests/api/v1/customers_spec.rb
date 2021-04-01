require 'swagger_helper'

RSpec.describe '/api/v1/customers', type: :request do
  path '/api/v1/customers' do
    get 'All Customers' do
      tags 'Customers'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
