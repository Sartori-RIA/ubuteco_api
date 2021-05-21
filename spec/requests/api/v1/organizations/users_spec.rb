require 'swagger_helper'

RSpec.describe Api::V1::Organizations::UsersController, type: :request do
  path 'api/v1/organizations/{organization_id}/users' do
    get 'All Organization users' do
      tags 'Organization Users'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :organization_id, in: :path, type: :string
      response '200', 'Ok' do
        let(:Authorization) { "Bearer #{auth_header(user)}" }
        run_test!
      end
    end
  end
end
