# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cross-tenant access', type: :request do
  let(:organization_a) { create(:organization) }
  let(:organization_b) { create(:organization) }
  let(:waiter_a) { create(:user, :waiter, organization: organization_a) }
  let(:admin_a) { organization_a.user }

  describe 'orders' do
    let!(:order_b) { create(:order, organization: organization_b) }

    it 'forbids show on another organization order' do
      get api_v1_order_path(order_b), headers: auth_header(waiter_a)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'dishes' do
    let!(:dish_b) { create(:dish, organization: organization_b) }

    it 'forbids show on another organization dish' do
      get api_v1_dish_path(dish_b), headers: auth_header(admin_a)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'users' do
    let!(:user_b) { create(:user, :waiter, organization: organization_b) }

    it 'forbids show on another organization user' do
      get api_v1_user_path(user_b), headers: auth_header(admin_a)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'kitchen queue' do
    let(:customer_b) { create(:user, :customer) }
    let!(:order_b) { create(:order, :with_items, organization: organization_b, user: customer_b) }
    let(:kitchen_a) { create(:user, :kitchen, organization: organization_a) }

    it 'does not include dishes from another organization' do
      get api_v1_kitchens_path, headers: auth_header(kitchen_a)

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body.pluck('id')
      order_b.order_items.each do |item|
        expect(ids).not_to include(item.id)
      end
    end
  end
end
