# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KitchenCableBroadcaster do
  include ActionCable::TestHelper

  let(:organization) { create(:organization) }
  let(:stream) { "kitchens_#{organization.id}" }
  let(:message) { { obj: { id: 1, status: 'awaiting' }, action: 'create' } }

  it 'broadcasts to the organization kitchen stream' do
    expect do
      described_class.deliver(organization_id: organization.id, message: message)
    end.to have_broadcasted_to(stream).with(
      hash_including('action' => 'create', 'obj' => hash_including('id' => 1))
    )
  end
end
