require 'swagger_helper'

RSpec.describe Api::V1::KitchensController, type: :request do
  before :all do
    @user = create(:user_kitchen)
  end

  path '/api/v1/kitchens' do
    get 'All Dishes to make' do
      tags 'Kitchen'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        run_test!
      end
    end
  end
  path '/api/v1/kitchens/{dish_id}' do
    put 'Update dish preparation statuses' do
      tags 'Kitchen'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@user)['Authorization'] }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
end
