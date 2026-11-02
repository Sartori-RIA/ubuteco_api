# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Assistant conversations API', type: :request do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:admin) { organization.user }
  let(:Authorization) { auth_header(admin)['Authorization'] }

  before do
    ENV['AI_ENABLED'] = '1'
  end

  after do
    ENV.delete('AI_ENABLED')
  end

  path '/api/v1/assistant/conversations' do
    get 'List own conversations' do
      tags 'Assistant'
      security [Bearer: {}]
      produces 'application/json'

      response '200', 'Ok' do
        run_test!
      end
    end

    post 'Create a conversation' do
      tags 'Assistant'
      security [Bearer: {}]
      produces 'application/json'

      response '201', 'Created' do
        run_test!
      end
    end
  end

  path '/api/v1/assistant/conversations/{id}/messages' do
    post 'Ask the assistant' do
      tags 'Assistant'
      security [Bearer: {}]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: { content: { type: :string } },
        required: ['content']
      }

      response '201', 'Created' do
        let(:id) { AiConversation.create!(organization:, user: admin).id }
        let(:body) { { content: 'Quanto vendi ontem?' } }

        run_test!
      end
    end
  end
end
