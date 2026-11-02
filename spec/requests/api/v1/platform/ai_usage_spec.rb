# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Platform AI usage', type: :request do
  let!(:organization) { create(:organization) }
  let!(:super_admin) { create(:user, :super_admin, organization: nil) }
  let!(:admin) { organization.user }

  path '/api/v1/platform/ai_usage' do
    get 'AI usage totals (platform)' do
      tags 'Platform'
      security [Bearer: {}]
      produces 'application/json'
      parameter name: :from, in: :query, type: :string, required: false
      parameter name: :to, in: :query, type: :string, required: false

      response '200', 'Ok' do
        let(:Authorization) { auth_header(super_admin)['Authorization'] }
        schema '$ref' => '#/components/schemas/ai_usage'

        run_test!
      end

      response '403', 'Forbidden' do
        let(:Authorization) { auth_header(admin)['Authorization'] }

        run_test!
      end
    end
  end
end
