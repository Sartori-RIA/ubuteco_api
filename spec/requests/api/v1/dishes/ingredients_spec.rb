require 'swagger_helper'

RSpec.describe Api::V1::Dishes::IngredientsController, type: :request do
  path '/api/v1/dishes/{dish_id}/ingredients' do
    get 'All ingredients in dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :dish_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
    post 'Add new ingredient to dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :dish_id, in: :path, type: :string
      parameter in: :body, type: :object,
                schema: {
                  properties: {
                    id: { type: :integer },
                    quantity: { type: :string },
                    food_id: { type: :integer }
                  },
                  required: %w[quantity food_id]
                }
      response '201', 'Created' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 food_id: { type: :integer },
                 dish_id: { type: :integer },
                 quantity: { type: :integer },
               },
               required: %w[id food_id food dish_id dish quantity]
        run_test!
      end
      response '422', 'Invalid request' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
  path '/api/v1/dishes/{dish_id}/ingredients/{id}' do
    put 'Update ingredient in dish' do
      tags 'Dish ingredients'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :dish_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter in: :body, type: :object,
                schema: {
                  properties: {
                    quantity: { type: :string },
                  },
                  required: %w[quantity]
                }
      response '200', 'Ok' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 food_id: { type: :integer },
                 dish_id: { type: :integer },
                 quantity: { type: :integer },
               },
               required: %w[id food_id food dish_id dish quantity]
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
      parameter name: :id, in: :path, type: :string
    end
  end
end
