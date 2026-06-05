# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReindexJob, type: :job do
  let(:organization) { create(:organization) }
  let(:beer) { create(:beer, organization: organization) }

  it 'reindexes a single record when record_id is given' do
    expect(Beer).to receive(:find_by).with(id: beer.id).and_return(beer)
    expect(beer).to receive(:reindex)

    described_class.new.perform('Beer', beer.id)
    expect(Current.organization).to be_nil
  end

  it 'reindexes only records for the given organization' do
    expect(Beer).to receive(:reindex_for_organization).with(organization.id)

    described_class.new.perform('Beer', nil, organization.id)
    expect(Current.organization).to be_nil
  end

  it 'reindexes the organization record when model is Organization' do
    relation = Organization.where(id: organization.id)
    allow(Organization).to receive(:find_by).and_call_original
    allow(Organization).to receive(:where).and_call_original
    allow(Organization).to receive(:where).with(id: organization.id).and_return(relation)
    expect(relation).to receive(:reindex)

    described_class.new.perform('Organization', nil, organization.id)
    expect(Current.organization).to be_nil
  end

  it 'refuses full-class reindex without record or organization scope' do
    expect do
      described_class.new.perform('Organization', nil, nil)
    end.to raise_error(ArgumentError, /Full-class reindex disabled/)
  end

  it 'enqueues on the searchkick queue' do
    expect(described_class.get_sidekiq_options['queue']).to eq(:searchkick)
  end
end
