# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Assistant conversations', type: :request do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:admin) { organization.user }
  let(:headers) { auth_header(admin) }

  around do |example|
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'stores a question and returns the assistant answer' do
    Ai::FakeClient.enqueue(Ai.result(text: 'Ontem vendeu pouco.', tool_calls: []))

    post api_v1_assistant_conversations_path, headers: headers
    conversation_id = response.parsed_body['id']

    post messages_api_v1_assistant_conversation_path(conversation_id),
         params: { content: 'Quanto vendi ontem?' },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body.dig('message', 'text')).to eq('Ontem vendeu pouco.')

    get api_v1_assistant_conversation_path(conversation_id), headers: headers

    roles = response.parsed_body['messages'].pluck('role')
    expect(roles).to eq(%w[user assistant])
  end

  it 'lets a cash register ask and blocks a waiter' do
    cashier = create(:user, :cash_register, organization:)
    waiter = create(:user, :waiter, organization:)
    Ai::FakeClient.enqueue(Ai.result(text: 'ok', tool_calls: []))

    post api_v1_assistant_conversations_path, headers: auth_header(cashier)
    expect(response).to have_http_status(:created)

    post api_v1_assistant_conversations_path, headers: auth_header(waiter)
    expect(response).to have_http_status(:forbidden)
  end

  it 'rejects a blank question and deletes a conversation' do
    post api_v1_assistant_conversations_path, headers: headers
    conversation_id = response.parsed_body['id']

    post messages_api_v1_assistant_conversation_path(conversation_id),
         params: { content: '   ' },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:unprocessable_content)

    delete api_v1_assistant_conversation_path(conversation_id), headers: headers

    expect(response).to have_http_status(:no_content)
    expect(AiConversation.find_by(id: conversation_id)).to be_nil
  end

  it 'returns ai_disabled when the organization is opted out' do
    organization.update!(ai_enabled: false)

    post api_v1_assistant_conversations_path, headers: headers

    expect(response).to have_http_status(:forbidden)
    expect(response.parsed_body.dig('errors', 0, 'code')).to eq('ai_disabled')
  end

  it 'does not show another user conversation in the same organization' do
    other = create(:user, :cash_register, organization:)
    conversation = AiConversation.create!(organization:, user: admin, title: 'mine')

    get api_v1_assistant_conversation_path(conversation), headers: auth_header(other)

    expect(response).to have_http_status(:not_found)
  end

  it 'does not show a conversation from another organization' do
    foreign = create(:organization, ai_enabled: true)
    conversation = AiConversation.create!(organization: foreign, user: foreign.user, title: 'theirs')

    get api_v1_assistant_conversation_path(conversation), headers: headers

    expect(response).to have_http_status(:not_found)
  end
end
