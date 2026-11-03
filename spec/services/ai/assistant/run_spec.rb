# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::Assistant::Run do
  let(:organization) { create(:organization, ai_enabled: true, locale: 'pt-BR') }
  let(:admin) { organization.user }
  let(:conversation) { AiConversation.create!(organization:, user: admin) }
  let(:ability) do
    Abilities::AdminAbility.new(
      user: admin,
      params: {},
      controller_name: 'Api::V1::Assistant::Conversations'
    )
  end

  around do |example|
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'runs two tools and then returns the final answer' do
    conversation.ai_messages.create!(role: 'user', content: { text: 'Como está o estoque?' })
    Ai::FakeClient.enqueue(
      Ai.result(
        text: '',
        tool_calls: [
          Ai::ToolCall.new(id: 'call-low', name: 'low_stock', input: {}),
          Ai::ToolCall.new(id: 'call-exp', name: 'expiring_products', input: {})
        ]
      )
    )
    Ai::FakeClient.enqueue(Ai.result(text: 'Nada critico.', tool_calls: []))

    text = described_class.call(conversation:, user: admin, organization:, ability:)

    expect(text).to eq('Nada critico.')
    expect(conversation.ai_messages.where(role: 'tool').pluck(:tool_name)).to eq(%w[low_stock expiring_products])
    tool_round = Ai::FakeClient.calls.last[:messages].to_json
    expect(tool_round).to include('tool_result')
    expect(tool_round).to include('low_stock')
    expect(AiUsageEvent.where(feature: 'assistant', status: 'ok').count).to eq(2)
  end

  it 'tells the model when the tool does not exist' do
    conversation.ai_messages.create!(role: 'user', content: { text: 'Apaga tudo' })
    Ai::FakeClient.enqueue(
      Ai.result(text: '', tool_calls: [Ai::ToolCall.new(id: 'call-x', name: 'delete_stock', input: {})])
    )
    Ai::FakeClient.enqueue(Ai.result(text: 'Não posso apagar.', tool_calls: []))

    described_class.call(conversation:, user: admin, organization:, ability:)

    payload = conversation.ai_messages.find_by(tool_name: 'delete_stock').content
    expect(payload['result']).to eq('error' => 'unknown_tool')
  end
end
