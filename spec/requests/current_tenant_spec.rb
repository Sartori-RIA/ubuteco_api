# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Current tenant context', type: :request do
  describe 'SetCurrentTenant' do
    let(:organization) { create(:organization) }

    it 'allows org-scoped staff with an organization' do
      waiter = create(:user, :waiter, organization: organization)

      get api_v1_orders_path, headers: auth_header(waiter)

      expect(response).to have_http_status(:ok)
    end

    it 'rejects org-scoped staff without an organization' do
      waiter = create(:user, :waiter, organization: nil)

      get api_v1_orders_path, headers: auth_header(waiter)

      expect(response).to have_http_status(:forbidden)
    end

    it 'forbids super admin on org operational routes without platform context' do
      super_admin = create(:user, :super_admin, organization: nil)

      get api_v1_orders_path, headers: auth_header(super_admin)

      expect(response).to have_http_status(:forbidden)
    end

    it 'allows customer without an organization' do
      customer = create(:user, :customer, organization: nil)

      get api_v1_user_path(customer), headers: auth_header(customer)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Current reset after request' do
    it 'clears Current when the request completes' do
      admin = create(:organization).user

      get api_v1_orders_path, headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      expect(Current.user).to be_nil
      expect(Current.organization).to be_nil
    end
  end
end
