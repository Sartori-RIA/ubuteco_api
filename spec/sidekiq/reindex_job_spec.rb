# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReindexJob, type: :job do
  let(:organization) { create(:organization) }

  it 'reindexes only records for the given organization' do
    expect(Beer).to receive(:reindex_for_organization).with(organization.id)

    described_class.new.perform('Beer', organization.id)
    expect(Current.organization).to be_nil
  end

  it 'reindexes the full model when organization_id is nil' do
    expect(Organization).to receive(:reindex)

    described_class.new.perform('Organization', nil)
    expect(Current.organization).to be_nil
  end
end
