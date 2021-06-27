# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Organizations::UsersController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }

  describe '#GET /api/organizations/:organization_id/users' do
    it 'retrieveses all customers' do
      get api_v1_organization_users_path(organization_id: organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end
end
