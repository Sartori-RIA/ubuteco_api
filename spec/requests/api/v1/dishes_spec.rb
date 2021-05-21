require 'swagger_helper'

RSpec.describe Api::V1::DishesController, type: :request do

  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @dishes = create_list(:dish, 10, organization: @organization)
  end

  path '/api/v1/dishes' do
    get 'All Dishes' do
      tags 'Dishes'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/dishes'
        run_test!
      end
    end
    post 'Create a Dish' do
      tags 'Dishes'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_dish' }
      response 201, 'Created' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:dish) }
        schema '$ref' => '#/components/schemas/dish'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/dishes/{id}' do
    get 'Show Dish' do
      tags 'Dishes'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @dishes.sample.id }
        schema '$ref' => '#/components/schemas/dish'
        run_test!
      end
    end
    put 'Update a Dish' do
      tags 'Dishes'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/dish' }
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @dishes.sample.id }
        let(:params) { attributes_for(:dish) }
        schema '$ref' => '#/components/schemas/dish'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @dishes.sample.id }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Dish' do
      tags 'Dishes'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @dishes.sample.id }
        run_test!
      end
    end
  end
  path '/api/v1/dishes/search' do
    get 'Search dish by name' do
      tags 'Dishes'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:q) { 'tralala' }
        schema '$ref' => '#/components/schemas/dishes'
        run_test!
      end
    end
  end
end
