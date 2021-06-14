require 'swagger_helper'

RSpec.describe Api::V1::Dishes::IngredientsController, type: :request do
  before :all do
    @organization = create(:organization)
    @user = @organization.user
    @foods = create_list(:food, 10, organization: @organization)
    @dish = create(:dish, :with_ingredients, organization: @organization)
  end

  path '/api/v1/dishes/{dish_id}/ingredients' do
    get 'All ingredients in dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      security [Bearer: {}]
      parameter name: :dish_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:dish_id) { @dish.id }
        schema '$ref' => '#/components/schemas/dish_ingredients'
        run_test!
      end
    end
    post 'Add new ingredient to dish' do
      tags 'Dish ingredients'
      consumes 'application/json'
      security [Bearer: {}]
      parameter name: :dish_id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_dish_ingredient' }
      response '201', 'Created' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:dish_id) { @dish.id }
        let(:params) { attributes_for(:dish_ingredient).merge(food_id: @foods.sample.id) }
        schema '$ref' => '#/components/schemas/dish_ingredient'
        run_test!
      end
      response '422', 'Invalid request' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:dish_id) { @dish.id }
        let(:params) { {} }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/dishes/{dish_id}/ingredients/{id}' do
    put 'Update ingredient in dish' do
      tags 'Dish ingredients'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :dish_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/edit_dish_ingredient' }
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:dish_id) { @dish.id }
        let(:id) { @dish.dish_ingredients.sample.id }
        let(:params) { attributes_for(:dish_ingredient) }
        schema '$ref' => '#/components/schemas/theme'
        run_test!
      end
      response '422', 'Invalid request' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:dish_id) { @dish.id }
        let(:id) { @dish.dish_ingredients.sample.id }
        let(:params) { { quantity: -1 } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Remove ingredient from dish' do
      tags 'Dish ingredients'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :dish_id, in: :path, type: :string
      parameter name: :id, in: :path, type: :string
      response '204', 'No Content' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        let(:dish_id) { @dish.id }
        let(:id) { @dish.dish_ingredients.sample.id }
        run_test!
      end
    end
  end
end
