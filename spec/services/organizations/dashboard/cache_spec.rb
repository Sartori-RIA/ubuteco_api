# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organizations::Dashboard::Cache do
  let(:organization) { create(:organization) }

  around do |example|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache.lookup_store(:memory_store)
    Rails.cache.clear
    example.run
  ensure
    Rails.cache = original_cache
  end

  it 'caches dashboard payloads by org and params' do
    calls = 0
    block = lambda do |*_args|
      calls += 1
      { value: 1 }
    end

    2.times do
      described_class.fetch(org: organization, kind: :summary, from: '2026-05-01', to: '2026-05-07', &block)
    end

    expect(calls).to eq(1)
  end
end
