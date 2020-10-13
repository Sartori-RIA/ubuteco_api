require 'rails_helper'

RSpec.describe Api::KitchensController, type: :request do
  let!(:user) { create(:user_restaurant) }
  let!(:orders) { create_list(:order_with_dish, 10, user: user) }

  describe "#GET /api/kitchens" do
    it 'should retrieves all kitchen orders' do
      get api_kitchens_path, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end
  describe "#PUT /api/kitchens/:id" do
    it 'should update order' do
      item = orders.sample.order_items.sample
      put api_kitchen_path(item.id), params: item.to_json, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end
end