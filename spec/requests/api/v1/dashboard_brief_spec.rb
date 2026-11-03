# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Dashboard brief API', type: :request do
  path '/api/v1/dashboard/brief' do
    get 'Daily brief' do
      tags 'Dashboard'
      security [Bearer: {}]
      produces 'application/json'
      parameter name: :refresh, in: :query, type: :boolean, required: false

      response '200', 'Ok' do
        let(:organization) { create(:organization) }
        let(:Authorization) { auth_header(organization.user)['Authorization'] }
        let(:refresh) { false }

        run_test!
      end
    end
  end
end
