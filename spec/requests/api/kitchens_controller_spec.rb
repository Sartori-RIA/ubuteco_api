require 'rails_helper'

RSpec.describe Api::KitchensController, type: :request do
  before :each do
    @organization = create :organization
    @admin = @organization.user
    @admin.update(organization: @organization)
    @kitchen = create :user_kitchen, organization: @organization
    @orders = create_list :order_with_dish, 10, organization: @organization
  end

  describe "#GET /api/kitchens" do
    it 'should retrieves all kitchen orders' do
      get api_kitchens_path, headers: auth_header(@kitchen)
      expect(response).to have_http_status(200)
    end
  end
  describe "#PUT /api/kitchens/:id" do
    it 'should update order' do
      item = @orders.sample.order_items.sample
      put api_kitchen_path(item.id), params: item.to_json, headers: auth_header(@kitchen)
      expect(response).to have_http_status(200)
    end
  end
end
