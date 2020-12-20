require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :request do
  let!(:organization) { create :organization }
  let!(:admin) do
    organization.user.update(organization: organization)
    organization.user
  end
end
