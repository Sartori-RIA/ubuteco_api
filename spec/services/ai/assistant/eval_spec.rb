# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::Assistant::Eval do
  let(:organization) { create(:organization, ai_enabled: true) }

  it 'scores the checked-in cases without calling the network' do
    previous = ENV.fetch('AI_EVAL_ORGANIZATION_ID', nil)
    ENV['AI_EVAL_ORGANIZATION_ID'] = organization.id.to_s
    allow(Ai::Assistant::Run).to receive(:call).and_return('sem dados')

    result = described_class.call

    expect(result[:total]).to eq(5)
    expect(result[:passed]).to be < result[:total]
  ensure
    previous.nil? ? ENV.delete('AI_EVAL_ORGANIZATION_ID') : ENV['AI_EVAL_ORGANIZATION_ID'] = previous
  end
end
