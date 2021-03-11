require 'rails_helper'

RSpec.describe KitchenChannel, type: :channel do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }
  let(:channel_name) { "kitchens_#{organization.cnpj}" }

  xdescribe '#CHANNEL' do
    before do
      # initialize connection with identifiers
      stub_connection user_id: user.id
    end

    it "subscribes without streams when no room id" do
      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).not_to have_streams
    end

    it "rejects when room id is invalid" do
      subscribe(room_id: -1)

      expect(subscription).to be_rejected
    end

    it "subscribes to a stream when room id is provided" do
      subscribe(room_id: 42)

      expect(subscription).to be_confirmed

      # check particular stream by name
      expect(subscription).to have_stream_from("chat_42")

      # or directly by model if you create streams with `stream_for`
      expect(subscription).to have_stream_for(Room.find(42))
    end
  end
end
