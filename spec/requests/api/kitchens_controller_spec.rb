require 'rails_helper'

RSpec.describe Api::KitchensController, type: :request do

  let!(:organization) { create :organization }
  let!(:admin) do
    organization.user.update(organization: organization)
    organization.user
  end
  let!(:kitchen) { create :user_kitchen, organization: organization }
  let!(:orders) { create_list :order_with_dish, 10, organization: organization }

  describe "#GET /api/kitchens" do
    it 'should retrieves all kitchen orders' do
      get api_kitchens_path, headers: auth_header(kitchen)
      expect(response).to have_http_status(200)
    end
  end
  describe "#PUT /api/kitchens/:id" do
    let!(:item) { orders.sample.order_items.sample }
    it 'should update order' do
      put api_kitchen_path(item.id), params: item.to_json, headers: auth_header(kitchen)
      expect(response).to have_http_status(200)
    end
  end
end
