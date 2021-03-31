require 'rails_helper'

RSpec.describe Api::KitchensController, type: :request do

  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:kitchen) { create(:user_kitchen, organization: organization) }
  let!(:orders) { create_list(:order, 10, :with_dish, organization: organization) }
  let!(:foods) { create_list(:food, 10, organization: organization) }
  let!(:dishes) { create_list(:dish, 10, organization: organization) }
  let!(:dish_ingredients) { dishes.map { |dish| create_list(:dish_ingredient, 10, food: foods.sample, dish: dish) } }

  describe "#GET /api/kitchens" do
    it 'should retrieves all kitchen orders' do
      get api_v1_kitchens_path, headers: auth_header(kitchen)
      expect(response).to have_http_status(200)
    end
  end
  describe "#PUT /api/kitchens/:id" do
    let!(:item) { orders.sample.order_items.sample }
    it 'should update order' do
      put api_v1_kitchen_path(id: item.id), params: item.to_json, headers: auth_header(kitchen)
      expect(response).to have_http_status(200)
    end
  end
end
