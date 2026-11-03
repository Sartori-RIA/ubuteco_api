# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organizations::DailyBrief::Compose do
  let(:organization) { create(:organization, ai_enabled: true, locale: 'en') }

  around do |example|
    previous = ENV.fetch('AI_ENABLED', nil)
    ENV['AI_ENABLED'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('AI_ENABLED') : ENV['AI_ENABLED'] = previous
  end

  it 'uses the template when the model invents a number or the provider fails' do
    Ai::FakeClient.enqueue(Ai.result(text: 'Revenue was 99 yesterday.'))
    invented = described_class.call(organization:)
    expect(invented[:source]).to eq('template')

    Ai::FakeClient.enqueue(Ai::ProviderError.new('down'))
    failed = described_class.call(organization:)
    expect(failed[:source]).to eq('template')
    expect(failed[:text]).to include('Yesterday')
  end

  it 'keeps a sentence that only repeats numbers from the facts' do
    facts = Organizations::DailyBrief::Facts.call(organization:)
    Ai::FakeClient.enqueue(Ai.result(text: "Low stock: #{facts[:low_stock_count]}."))

    brief = described_class.call(organization:)

    expect(brief[:source]).to eq('ai')
    expect(brief[:text]).to include(facts[:low_stock_count].to_s)
  end

  it 'uses the template when AI is off' do
    organization.update!(ai_enabled: false)

    brief = described_class.call(organization:)

    expect(brief[:source]).to eq('template')
  end
end
