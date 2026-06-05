# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchkickReindex do
  let(:organization) { create(:organization) }

  describe '.model!' do
    it 'reindexes the given model' do
      expect(Beer).to receive(:reindex)

      described_class.model!('Beer')
    end

    it 'raises for unknown models' do
      expect { described_class.model!('NotAModel') }.to raise_error(ArgumentError, /Unknown Searchkick model/)
    end
  end

  describe '.organization!' do
    it 'reindexes the organization and org-scoped models' do
      expect(Organization).to receive(:find).with(organization.id).and_return(organization)
      expect(organization).to receive(:reindex)

      SearchkickModels.all.each do |model|
        next if model == Organization

        expect(model).to receive(:reindex_for_organization).with(organization.id)
      end

      described_class.organization!(organization.id)
    end
  end
end
