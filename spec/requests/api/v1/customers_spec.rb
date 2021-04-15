require 'swagger_helper'

RSpec.describe Api::V1::CustomersController, type: :request do

  before :all do
    @organization = create(:organization)
    @admin = @organization.user
  end

  path '/api/v1/customers' do
    get 'All Customers' do
      tags 'Customers'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@admin)['Authorization'] }
        run_test!
      end
    end
  end
end
