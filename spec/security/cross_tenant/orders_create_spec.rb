# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cross-tenant order create', type: :request do
  let(:organization_a) { create(:organization) }
  let(:organization_b) { create(:organization) }
  let(:waiter) { create(:user, :waiter, organization: organization_a) }

  it 'ignores a foreign organization_id and assigns the user organization' do
    attributes = attributes_for(:order).merge(organization_id: organization_b.id)

    post api_v1_orders_path,
         params: attributes.to_json,
         headers: auth_header(waiter)

    expect(response).to have_http_status(:created)
    order = Order.order(:id).last
    expect(order.organization_id).to eq(organization_a.id)
    expect(order.organization_id).not_to eq(organization_b.id)
  end
end
