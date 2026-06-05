# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Platform hardening", type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }
  let(:waiter) { create(:user, :waiter, organization: organization) }
  let(:kitchen_user) { create(:user, :kitchen, organization: organization) }
  let(:super_admin) { create(:user, :super_admin, organization: nil) }
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

    it "returns errors_response on invalid beer create" do
      post api_v1_beers_path,
           params: {}.to_json,
           headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")
    end

    it "returns errors_response on invalid maker update" do
      maker = create(:maker, organization: organization)

      put api_v1_maker_path(maker),
          params: { name: nil }.to_json,
          headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")
    end

    it "returns errors_response when order destroy fails" do
      order = create(:order, organization: organization, user: waiter)
      allow_any_instance_of(Order).to receive(:destroy) do |record|
        record.errors.add(:base, "Cannot delete order")
        false
      end

      delete api_v1_order_path(order), headers: auth_header(waiter)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")
    end

    it "uses organization locale for validation messages and field keys" do
      organization.update!(locale: "pt-BR")
      admin.reload

      post api_v1_beers_path,
           params: {}.to_json,
           headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      errors = response.parsed_body.fetch("errors")
      messages = errors.pluck("message").join(" ")
      fields = errors.pluck("field")

      expect(messages).to include("Nome não pode ficar em branco")
      expect(messages).to include("Fabricante é obrigatório(a)")
      expect(fields).to include("name", "maker")
    end

    it "uses English attribute labels when organization locale is en" do
      organization.update!(locale: "en")
      admin.reload

      post api_v1_beers_path,
           params: {}.to_json,
           headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      messages = response.parsed_body.fetch("errors").pluck("message").join(" ")

      expect(messages).to match(/Name.*blank/i)
      expect(messages).to match(/Maker must exist/i)
    end
  end

  describe "destroy failure errors" do
    def stub_failed_destroy!(model_class)
      allow_any_instance_of(model_class).to receive(:destroy) do |record|
        record.errors.add(:base, "Cannot delete")
        false
      end
    end

    it "returns errors_response when destroy fails" do
      beer = create(:beer, organization: organization)
      stub_failed_destroy!(Beer)
      delete api_v1_beer_path(beer), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      beer_style = create(:beer_style)
      stub_failed_destroy!(BeerStyle)
      delete api_v1_beer_style_path(beer_style), headers: auth_header(super_admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      dish = create(:dish, organization: organization)
      stub_failed_destroy!(Dish)
      delete api_v1_dish_path(dish), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      dish = create(:dish, :with_ingredients, organization: organization)
      ingredient = dish.dish_ingredients.first
      stub_failed_destroy!(DishIngredient)
      delete api_v1_dish_ingredient_path(dish, ingredient), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      drink = create(:drink, organization: organization)
      stub_failed_destroy!(Drink)
      delete api_v1_drink_path(drink), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      food = create(:food, organization: organization)
      stub_failed_destroy!(Food)
      delete api_v1_food_path(food), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      maker = create(:maker, organization: organization)
      stub_failed_destroy!(Maker)
      delete api_v1_maker_path(maker), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      table = create(:table, organization: organization)
      stub_failed_destroy!(Table)
      delete api_v1_table_path(table), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      user = create(:user, :waiter, organization: organization)
      stub_failed_destroy!(User)
      delete api_v1_user_path(user), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      wine = create(:wine, organization: organization)
      stub_failed_destroy!(Wine)
      delete api_v1_wine_path(wine), headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      wine_style = create(:wine_style)
      stub_failed_destroy!(WineStyle)
      delete api_v1_wine_style_path(wine_style), headers: auth_header(super_admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      role = create(:role)
      stub_failed_destroy!(Role)
      delete api_v1_role_path(role), headers: auth_header(super_admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      other_org = create(:organization)
      stub_failed_destroy!(Organization)
      delete api_v1_organization_path(other_org), headers: auth_header(other_org.user)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")
    end
  end

  describe "platform organization errors" do
    it "returns errors_response on invalid update and failed destroy" do
      target = create(:organization)

      put api_v1_platform_organization_path(target),
          params: { name: nil }.to_json,
          headers: auth_header(super_admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")

      allow_any_instance_of(Organization).to receive(:destroy) do |record|
        record.errors.add(:base, "Cannot delete")
        false
      end
      delete api_v1_platform_organization_path(target), headers: auth_header(super_admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "validation_error")
    end
  end

  describe "orders association preloading" do
    it "preloads associations on index when orders exist", search: true do
      create(:order, organization: organization, user: waiter)
      reindex_searchkick!(Order)

      get api_v1_orders_path, headers: auth_header(waiter)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data")).to be_an(Array)
      expect(response.parsed_body.dig("data")).not_to be_empty
    end

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
      allow(Kitchen::UpdateItemStatus).to receive(:call)
        .and_raise(Kitchen::UpdateItemStatus::KitchenClosed)

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
    it "returns invalid_range on summary" do
      get "/api/v1/dashboard/summary",
          params: { from: to, to: from },
          headers: auth_header(admin)

      expect(response).to have_http_status(:unprocessable_content)
      expect_errors_response!(code: "invalid_range")
    end

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
