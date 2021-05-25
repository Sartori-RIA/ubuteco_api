require 'rails_helper'

RSpec.describe Api::V1::KitchensController, type: :request do

  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @kitchen = create(:user_kitchen, organization: @organization)
    @orders = create_list(:order, 10, :with_dish, organization: @organization)
    @foods = create_list(:food, 10, organization: @organization)
    @dishes = create_list(:dish, 10, organization: @organization)
    @dish_ingredients = @dishes.map { |dish| create_list(:dish_ingredient, 10, food: @foods.sample, dish: dish) }
  end


  describe "#GET /api/kitchens" do
    it 'should retrieves all kitchen orders' do
      get api_v1_kitchens_path, headers: auth_header(kitchen)
      expect(response).to have_http_status(200)
    end
  end
  describe "#PUT /api/kitchens/:id" do
    let!(:item) { @orders.sample.order_items.sample }
    it 'should update order' do
      put api_v1_kitchen_path(id: item.id), params: item.to_json, headers: auth_header(@kitchen)
      expect(response).to have_http_status(200)
    end
  end
end
