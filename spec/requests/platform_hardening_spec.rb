# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Platform hardening", type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }
  let(:waiter) { create(:user, :waiter, organization: organization) }
  let(:kitchen_user) { create(:user, :kitchen, organization: organization) }
  let(:from) { 6.days.ago.to_date.iso8601 }
  let(:to) { Date.current.iso8601 }

  def expect_errors_response!(code: nil)
    body = response.parsed_body
    expect(body).to be_a(Hash)
    expect(body).to include("errors")
    expect(body["errors"]).to be_an(Array)
    expect(body["errors"].first).to include("code", "message")
    expect(body["errors"].first["code"]).to eq(code) if code
  end

  describe "standardized error format" do
    it "returns errors_response on invalid order create" do
      post api_v1_orders_path,
           params: attributes_for(:order).merge(discount: -1).to_json,
           headers: auth_header(waiter)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")
    end

    it "returns errors_response on invalid order update" do
      order = create(:order, organization: organization, user: waiter)

      put api_v1_order_path(order),
          params: { discount: -1 }.to_json,
          headers: auth_header(waiter)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")
    end

    it "returns delete_restriction when organization destroy raises restriction error" do
      restriction = ActiveRecord::DeleteRestrictionError.new("Cannot delete record because of dependent users")
      allow_any_instance_of(Organization).to receive(:destroy).and_raise(restriction)

      delete api_v1_organization_path(organization), headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "delete_restriction")
    end
  end

  describe "orders association preloading" do
    it "returns ok for index with no orders" do
      empty_org = create(:organization)
      empty_waiter = create(:user, :waiter, organization: empty_org)

      get api_v1_orders_path, headers: auth_header(empty_waiter)

      expect(response).to have_http_status(:ok)
    end

    it "returns ok for show with associations loaded" do
      order = create(:order, :with_items, organization: organization, user: waiter)

      get api_v1_order_path(order), headers: auth_header(waiter)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("table", "organization_id", "user_id")
    end
  end

  describe "kitchen updates" do
    let(:open_order) { create(:order, :open, organization: organization, user: waiter) }
    let(:dish) { create(:dish, organization: organization) }
    let!(:kitchen_item) { create(:order_item, order: open_order, item: dish, status: :awaiting) }

    it "returns kitchen_closed error when organization is closed" do
      # Skip CloseKitchen callback so the order stays open and the controller
      # reaches UpdateItemStatus (CanCan requires order.status == :open).
      organization.update_column(:operational_status, Organization.operational_statuses[:closed])

      put api_v1_kitchen_path(kitchen_item),
          params: { status: "cooking" }.to_json,
          headers: auth_header(kitchen_user)

      expect(response).to have_http_status(:forbidden)
      expect(response.media_type).to eq("application/json")
      expect_errors_response!(code: "kitchen_closed")
    end

    it "returns validation errors for invalid status transition" do
      put api_v1_kitchen_path(kitchen_item),
          params: { status: "with_the_client" }.to_json,
          headers: auth_header(kitchen_user)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")
      expect(kitchen_item.reload).to be_awaiting
    end
  end

  describe "dashboard invalid ranges" do
    it "returns invalid_range on series" do
      get "/api/v1/dashboard/series",
          params: { from: to, to: from, metric: "revenue", grain: "day" },
          headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "invalid_range")
    end

    it "returns invalid_range on kitchen metrics" do
      get "/api/v1/dashboard/kitchen",
          params: { from: to, to: from },
          headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "invalid_range")
    end
  end

  describe "request log payload" do
    it "includes user_id and organization_id in the action payload" do
      payload = nil
      subscriber = ActiveSupport::Notifications.subscribe("process_action.action_controller") do |event|
        payload = event.payload if event.payload[:controller] == "Api::V1::OrdersController"
      end

      get api_v1_orders_path, headers: auth_header(waiter)

      ActiveSupport::Notifications.unsubscribe(subscriber)

      expect(payload).to be_present
      expect(payload[:user_id]).to eq(waiter.id)
      expect(payload[:organization_id]).to eq(organization.id)
    end
  end
end
