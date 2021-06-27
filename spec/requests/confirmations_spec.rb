# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe ConfirmationsController, type: :request do
  before :all do
    @token = generate_code
    @user = create(:user, confirmed_at: nil, confirmation_token: @token)
  end

  path '/auth/confirmations' do
    get 'Account data after confirm' do
      tags 'Auth'
      consumes 'application/json'
      parameter name: :confirmation_token, in: :query, type: :string
      response '200', 'Ok' do
        let(:confirmation_token) { @token }
        schema '$ref' => '#/components/schemas/user'
        run_test!
      end
    end
  end
end
