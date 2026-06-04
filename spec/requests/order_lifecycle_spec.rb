# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Order lifecycle guards", type: :request do
  let(:organization) { create(:organization) }
  let(:waiter) { create(:user, :waiter, organization: organization) }
  let(:kitchen_user) { create(:user, :kitchen, organization: organization) }
  let(:open_order) { create(:order, :open, organization: organization, user: waiter) }
  let(:closed_order) { create(:order, :closed, organization: organization, user: waiter) }
  let(:drink) { create(:drink, organization: organization, quantity_stock: 10) }
  let(:dish) { create(:dish, organization: organization) }
  let!(:kitchen_item) { create(:order_item, order: open_order, item: dish, status: :awaiting) }

  describe "POST /api/v1/orders/:order_id/items" do
    it "rejects adding items to a closed order" do
      post api_v1_order_items_path(closed_order),
           params: {
             item_type: drink.model_name,
             item_id: drink.id,
             quantity: 1
           }.to_json,
           headers: auth_header(waiter)

      expect(response).to have_http_status(:forbidden)
    end

    it "includes the new item on the order items index after create" do
      post api_v1_order_items_path(open_order),
           params: {
             item_type: dish.model_name,
             item_id: dish.id,
             quantity: 1
           }.to_json,
           headers: auth_header(waiter)

      expect(response).to have_http_status(:created)
      created_id = response.parsed_body.fetch("id")

      get api_v1_order_items_path(open_order), headers: auth_header(waiter)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("id")).to include(created_id)
    end
  end

  describe "PUT /api/v1/kitchens/:id" do
    it "returns forbidden when organization kitchen is closed" do
      organization.update!(operational_status: :closed)

      put api_v1_kitchen_path(kitchen_item),
          params: { status: "cooking" }.to_json,
          headers: auth_header(kitchen_user)

      expect(response).to have_http_status(:forbidden)
      expect(kitchen_item.reload).to be_awaiting
    end
  end
end
