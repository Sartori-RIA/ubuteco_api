require 'rails_helper'

RSpec.describe KitchenChannel, type: :channel do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }
  let(:channel_name) { "kitchens_#{organization.cnpj}" }

  describe '#CHANNEL' do
    before do
      stub_connection current_user: admin
    end

    it "subscribes to a stream when kitchen room id is provided" do
      subscribe current_user: admin
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from(channel_name)
    end
  end
end
