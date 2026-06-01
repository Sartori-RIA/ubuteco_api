# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KitchenChannel, type: :channel do
  let(:organization_a) { create(:organization) }
  let(:organization_b) { create(:organization) }
  let(:kitchen_a) { create(:user, :kitchen, organization: organization_a) }

  describe '#subscribed' do
    it 'subscribes to the user organization stream only' do
      stub_connection current_user: kitchen_a

      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("kitchens_#{organization_a.id}")
      expect(subscription).not_to have_stream_from("kitchens_#{organization_b.id}")
    end

    it 'rejects users without an organization' do
      user = create(:user, :kitchen, organization: nil)
      stub_connection current_user: user

      subscribe

      expect(subscription).to be_rejected
    end
  end
end

