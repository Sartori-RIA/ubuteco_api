# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::AnthropicClient do
  let(:message) do
    usage = Struct.new(:input_tokens, :output_tokens).new(3, 5)
    text = Struct.new(:type, :text).new(:text, 'Hello')
    tool = Struct.new(:type, :id, :name, :input).new(:tool_use, 'tool_1', 'lookup', { 'q' => 'ipa' })
    Struct.new(:content, :usage, :stop_reason).new([text, tool], usage, :end_turn)
  end

  it 'maps text, tool calls, and token usage' do
    messages = double(create: message)
    client = described_class.new(tier: :fast, sdk: double(messages:))

    result = client.complete(system: 'sys', messages: [{ role: 'user', content: 'Hi' }], tools: nil)

    expect(result.text).to eq('Hello')
    expect(result.tool_calls.first.name).to eq('lookup')
    expect(result.usage.input_tokens).to eq(3)
    expect(result.usage.output_tokens).to eq(5)
    expect(result.stop_reason).to eq('end_turn')
  end

  it 'wraps provider failures' do
    messages = double
    allow(messages).to receive(:create).and_raise(Timeout::Error, 'timed out')
    client = described_class.new(tier: :smart, sdk: double(messages:))

    expect do
      client.complete(system: 'sys', messages: [], tools: nil)
    end.to raise_error(Ai::ProviderError, 'timed out')
  end
end
