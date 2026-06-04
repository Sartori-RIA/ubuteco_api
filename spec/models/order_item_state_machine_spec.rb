# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderItem, type: :model do
  let(:organization) { create(:organization) }
  let(:order) { create(:order, :open, organization: organization) }

  describe "dish status transitions" do
    let(:dish) { create(:dish, organization: organization) }
    let(:item) { create(:order_item, order: order, item: dish, status: :awaiting) }

    it "allows awaiting to cooking" do
      expect(item.update(status: :cooking)).to be true
    end

    it "allows cooking to ready" do
      item.update!(status: :cooking)

      expect(item.update(status: :ready)).to be true
    end

    it "allows ready to with_the_client" do
      item.update!(status: :cooking)
      item.update!(status: :ready)

      expect(item.update(status: :with_the_client)).to be true
    end

    it "rejects skipping cooking (awaiting to ready)" do
      expect(item.update(status: :ready)).to be false
      expect(item.errors[:status]).to include("cannot transition from awaiting to ready")
    end

    it "allows cancel from awaiting" do
      expect(item.update(status: :canceled)).to be true
    end
  end

  describe "non-dish status transitions" do
    let(:drink) { create(:drink, organization: organization) }
    let(:item) { create(:order_item, order: order, item: drink, status: :awaiting) }

    it "allows awaiting to with_the_client" do
      expect(item.update(status: :with_the_client)).to be true
    end

    it "rejects kitchen-only statuses" do
      expect(item.update(status: :cooking)).to be false
      expect(item.errors[:status]).to include("cannot transition from awaiting to cooking")
    end
  end

  describe "open order guard" do
    it "rejects new items on a closed order" do
      closed_order = create(:order, :closed, organization: organization)
      drink = create(:drink, organization: organization)

      item = build(:order_item, order: closed_order, item: drink)

      expect(item).not_to be_valid
      expect(item.errors[:order]).to include("must be open to add items")
    end
  end
end
