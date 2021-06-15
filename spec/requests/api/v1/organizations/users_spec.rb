require 'swagger_helper'

RSpec.describe Api::V1::Organizations::UsersController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:user) { organization.user }
  path '/api/v1/organizations/{organization_id}/users' do
    get 'All Organization users' do
      tags 'Organization Users'
      security [Bearer: {}]
      consumes 'application/json'
      parameter name: :organization_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:'Authorization') { auth_header(user)['Authorization'] }
        let(:organization_id) { organization.id }
        run_test!
      end
    end
  end
end
