require 'rails_helper'

RSpec.describe Api::CustomersController, type: :request do

  let(:organization) { create(:organization) }
  let(:admin) { organization.user }
  let(:cash_register) { create(:user_cash_register, organization: organization) }
  let(:waiter) { create(:user_waiter, organization: organization) }
  let(:kitchen) { create(:user_kitchen, organization: organization) }
  let(:super_admin) { create(:user_super_admin) }
  let!(:customers) { create_list(:user_customer, 10) }

  describe '#GET /api/customers' do
    context "with success" do
      it 'should retrieves all customers' do
        get api_v1_customers_path, headers: auth_header(admin)
        expect(response).to have_http_status(:ok)
      end
      it 'should retrieves all customers' do
        get api_v1_customers_path, headers: auth_header(super_admin)
        expect(response).to have_http_status(:ok)
      end
      it 'should retrieves all customers' do
        get api_v1_customers_path, headers: auth_header(cash_register)
        expect(response).to have_http_status(:ok)
      end
      it 'should retrieves all customers' do
        get api_v1_customers_path, headers: auth_header(waiter)
        expect(response).to have_http_status(:ok)
      end
    end
    context "forbidden access" do
      it 'cannot retrieves all customers to kitchen' do
        get api_v1_customers_path, headers: auth_header(kitchen)
        expect(response).to have_http_status(:forbidden)
      end
      it 'cannot retrieves all customers to customers' do
        get api_v1_customers_path, headers: auth_header(customers.sample)
        expect(response).to have_http_status(:forbidden)
      end
    end
    context "Unauthorized access" do
      it 'cannot retrieves all customers' do
        get api_v1_customers_path, headers: unauthenticated_header
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

end
