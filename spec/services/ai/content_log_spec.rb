# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::ContentLog do
  it 'stays off in production even when the flag is set' do
    allow(Rails.env).to receive(:production?).and_return(true)
    previous = ENV['AI_LOG_CONTENT']
    ENV['AI_LOG_CONTENT'] = '1'

    expect(described_class.enabled?).to be(false)
  ensure
    ENV['AI_LOG_CONTENT'] = previous
  end
end
