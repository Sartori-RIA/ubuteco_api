require 'swagger_helper'

RSpec.describe '/api/v1/dishes/{dish_id}/ingredients', type: :request do
  path '/api/v1/dishes/{dish_id}/ingredients' do
    get 'All ingredients in dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Add new ingredient to dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
  path '/api/v1/dishes/{dish_id}/ingredients/{food_id}' do
    put 'Update ingredient in dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Remove ingredient from dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
