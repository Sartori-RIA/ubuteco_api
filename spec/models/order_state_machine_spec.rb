# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order, type: :model do
  describe "status transitions" do
    it "allows open to closed" do
      order = create(:order, :open)

      expect(order.update(status: :closed)).to be true
      expect(order).to be_closed
    end

    it "allows open to payed" do
      order = create(:order, :open)

      expect(order.update(status: :payed)).to be true
      expect(order).to be_payed
    end

    it "allows closed to payed" do
      order = create(:order, :closed)

      expect(order.update(status: :payed)).to be true
      expect(order).to be_payed
    end

    it "rejects reopening a closed order" do
      order = create(:order, :closed)

      expect(order.update(status: :open)).to be false
      expect(order.errors[:status]).to include("cannot transition from closed to open")
    end

    it "rejects transitions from payed" do
      order = create(:order, :payed)

      expect(order.update(status: :open)).to be false
      expect(order.errors[:status]).to include("cannot transition from payed to open")
    end
  end
end
