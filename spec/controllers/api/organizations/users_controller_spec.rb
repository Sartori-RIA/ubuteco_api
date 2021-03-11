require 'rails_helper'

RSpec.describe Api::Organizations::UsersController, type: :request do

  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }

  describe '#GET /api/organizations/:organization_id/users' do
    it 'should retrieves all customers' do
      get api_organization_users_path(organization_id: organization.id), headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end
end
