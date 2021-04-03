require 'swagger_helper'

RSpec.describe Api::V1::Dishes::IngredientsController, type: :request do
  path '/api/v1/dishes/{dish_id}/ingredients' do
    get 'All ingredients in dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :dish_id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    post 'Add new ingredient to dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :dish_id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
  path '/api/v1/dishes/{dish_id}/ingredients/{food_id}' do
    put 'Update ingredient in dish' do
      tags 'Dish ingredients'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :dish_id, in: :path, type: :string
      parameter name: :food_id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    delete 'Remove ingredient from dish' do
      tags 'Dish ingredients'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :dish_id, in: :path, type: :string
      parameter name: :food_id, in: :path, type: :string
      response '401', 'Unauthorized' do
        run_test!
      end
      response '403', 'Forbidden' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
      response '404', 'Not Found' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
end
