require 'swagger_helper'

RSpec.describe Api::V1::RolesController, type: :request do
  before :all do
    @admin = create(:user, :user_super_admin)
    @roles = create_list(:role, 10)
  end

  path '/api/v1/roles' do
    get 'All Roles' do
      tags 'Roles'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/roles'
        run_test!
      end
    end
    post 'Create a Role' do
      tags 'Roles'
      security [Bearer: {}]
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/new_role' }
      response 201, 'Created' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:role) }
        schema '$ref' => '#/components/schemas/role'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) {}
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
  path '/api/v1/roles/{id}' do
    get 'Show Role' do
      tags 'Roles'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @roles.sample.id }
        schema '$ref' => '#/components/schemas/role'
        run_test!
      end
    end
    put 'Update a Role' do
      tags 'Roles'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/role' }
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:params) { attributes_for(:role) }
        let(:id) { @roles.sample.id }
        schema '$ref' => '#/components/schemas/role'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @roles.sample.id }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
    delete 'Destroy a Role' do
      tags 'Roles'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      response 204, 'No Content' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        let(:id) { @roles.sample.id }
        schema '$ref' => '#/components/schemas/beer_styles'
        run_test!
      end
    end
  end
end
