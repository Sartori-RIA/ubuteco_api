# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kitchen::BroadcastOrderItem do
  include ActionCable::TestHelper

  let(:organization) { create(:organization) }
  let(:order) { create(:order, :open, organization: organization) }
  let(:dish) { create(:dish, organization: organization) }

  it "broadcasts when order and kitchen are open" do
    item = create(:order_item, order: order, item: dish)

    expect do
      described_class.call(order_item: item, action: "update")
    end.to have_broadcasted_to("kitchens_#{organization.id}")
  end

  it "skips broadcast when organization kitchen is closed" do
    item = create(:order_item, order: order, item: dish)
    organization.update!(operational_status: :closed)

    expect do
      described_class.call(order_item: item, action: "update")
    end.not_to have_broadcasted_to("kitchens_#{organization.id}")
  end
end
