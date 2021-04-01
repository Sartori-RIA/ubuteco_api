require 'swagger_helper'

RSpec.describe 'api/v1/kitchens', type: :request do
  path '/api/v1/kitchens' do
    get 'All Dishes to make' do
      tags 'Kitchen'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/kitchens/{dish_id}' do
    put 'Update dish preparation statuses' do
      tags 'Kitchen'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
