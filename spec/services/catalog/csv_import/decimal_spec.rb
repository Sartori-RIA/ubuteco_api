# frozen_string_literal: true

require "rails_helper"

RSpec.describe Catalog::CsvImport::Decimal do
  it "accepts a dot and a comma as the decimal mark" do
    expect(described_class.parse("12.50")).to eq(BigDecimal("12.50"))
    expect(described_class.parse("12,50")).to eq(BigDecimal("12.50"))
  end

  it "rejects a thousands separator" do
    expect { described_class.parse("1.234,56") }.to raise_error(described_class::InvalidNumber)
    expect { described_class.parse("1,234.56") }.to raise_error(described_class::InvalidNumber)
  end
end
