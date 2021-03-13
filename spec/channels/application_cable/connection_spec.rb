require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do

  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }

  it "successfully connects" do
    header = auth_header(admin)
    connect "/api/cable?token=#{header['Authorization']}"
    expect(connection.current_user.id).to eq admin.id
  end

  it "rejects connection" do
    expect { connect "/api/cable" }.to have_rejected_connection
  end
end
