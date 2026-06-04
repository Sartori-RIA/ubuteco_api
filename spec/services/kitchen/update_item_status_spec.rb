# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kitchen::UpdateItemStatus do
  let(:organization) { create(:organization) }
  let(:order) { create(:order, :open, organization: organization) }
  let(:dish) { create(:dish, organization: organization) }
  let(:order_item) { create(:order_item, order: order, item: dish, status: :awaiting) }

  it "updates dish status when kitchen is open" do
    result = described_class.call(order_item: order_item, status: "cooking", organization: organization)

    expect(result).to be_cooking
  end

  it "raises when kitchen is closed" do
    organization.update!(operational_status: :closed)

    expect do
      described_class.call(order_item: order_item, status: "cooking", organization: organization)
    end.to raise_error(described_class::KitchenClosed)
  end

  it "rejects invalid transitions" do
    result = described_class.call(order_item: order_item, status: "ready", organization: organization)

    expect(result.errors[:status]).to be_present
  end
end
