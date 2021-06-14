require 'swagger_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @users = create_list(:user, 5, organization: @organization)
    @roles = create_list(:role, 5)
  end
  path '/api/v1/users' do
    post 'Create a User' do
      tags 'Users'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_user' }
      response 201, 'Created' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:user).merge(role_id: @roles.sample.id) }
        schema '$ref' => '#/components/schemas/user'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { {} }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/users/{id}' do
    get 'Show User' do
      tags 'Users'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @users.sample.id }
        schema '$ref' => '#/components/schemas/user'
        run_test!
      end
    end
    put 'Update a User' do
      tags 'Users'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/user' }
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:user) }
        let(:id) { @users.sample.id }
        schema '$ref' => '#/components/schemas/user'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @users.sample.id }
        let(:params) { { email: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a User' do
      tags 'Users'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @users.sample.id }
        run_test!
      end
    end
  end
  path '/api/v1/users/search' do
    get 'Search User by name or email' do
      tags 'Users'
      security [Bearer: {}]
      parameter name: :q, in: :query, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:q) { 'tralala' }
        schema '$ref' => '#/components/schemas/users'
        run_test!
      end
    end
  end
end
