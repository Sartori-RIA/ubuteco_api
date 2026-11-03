# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::Intake::Eval do
  it 'waits for invoice photos before scoring' do
    result = described_class.call

    expect(result[:total]).to eq(5)
    expect(result[:passed]).to eq(0)
    expect(result[:pending]).to be(true)
  end
end
