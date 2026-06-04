# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizations::CloseKitchen do
  it "closes all open orders when the organization kitchen is closed" do
    organization = create(:organization, operational_status: :closed)
    open_order = create(:order, :open, organization: organization)
    closed_order = create(:order, :closed, organization: organization)

    count = described_class.call(organization: organization)

    expect(count).to eq(1)
    expect(open_order.reload).to be_closed
    expect(closed_order.reload).to be_closed
  end

  it "returns zero when the organization kitchen is still open" do
    organization = create(:organization, operational_status: :open)
    create(:order, :open, organization: organization)

    expect(described_class.call(organization: organization)).to eq(0)
  end
end
