# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory::ExpiringProductsQuery do
  let(:organization) { create(:organization, timezone: 'America/Sao_Paulo') }
  let(:warning_days) { 7 }
  let(:morning) { Time.find_zone!('America/Sao_Paulo').local(2026, 11, 2, 9, 0) }

  def list(org = organization, **options)
    described_class.call(organization: org, warning_days:, **options)
  end

  it 'includes products expiring today and tomorrow and excludes null dates' do
    travel_to(morning) do
      today = create(:beer, organization:, name: 'Today', valid_until: Time.utc(2026, 11, 2, 18, 0))
      tomorrow = create(:food, organization:, name: 'Tomorrow', valid_until: Time.utc(2026, 11, 3, 15, 0))
      create(:beer, organization:, name: 'No date', valid_until: nil)
      create(:food, organization:, name: 'Next month', valid_until: Time.utc(2026, 12, 2, 15, 0))

      items = list

      expect(items.pluck(:name)).to eq(%w[Today Tomorrow])
      expect(items).to include(
        include(id: today.id, product_type: 'beers', status: 'expiring', days_remaining: 0),
        include(id: tomorrow.id, product_type: 'foods', status: 'expiring', days_remaining: 1)
      )
    end
  end

  it 'marks yesterday as expired and can hide expired rows' do
    travel_to(morning) do
      create(:beer, organization:, name: 'Yesterday', valid_until: Time.utc(2026, 11, 2, 1, 0))

      expect(list.pluck(:status)).to eq(['expired'])
      expect(list(include_expired: false)).to be_empty
    end
  end

  it 'uses the organization calendar date across timezones' do
    # 2026-11-02 03:30 UTC is Nov 2 in Sao Paulo and still Nov 1 in Toronto.
    travel_to(Time.utc(2026, 11, 2, 3, 30)) do
      stamp = Time.utc(2026, 11, 2, 2, 0)
      sao_paulo = create(:organization, timezone: 'America/Sao_Paulo')
      toronto = create(:organization, timezone: 'America/Toronto')
      create(:food, organization: sao_paulo, name: 'Border', valid_until: stamp)
      create(:food, organization: toronto, name: 'Border', valid_until: stamp)

      sao_item = list(sao_paulo).first
      toronto_item = list(toronto).first

      expect(sao_item).to include(status: 'expired', days_remaining: -1)
      expect(toronto_item).to include(status: 'expiring', days_remaining: 0)
    end
  end

  it 'ignores other organizations and soft-deleted products' do
    travel_to(morning) do
      other = create(:organization)
      create(:beer, organization: other, name: 'Other', valid_until: Time.utc(2026, 11, 2, 15, 0))
      gone = create(:food, organization:, name: 'Gone', valid_until: Time.utc(2026, 11, 2, 15, 0))
      gone.destroy

      expect(list).to be_empty
    end
  end

  it 'sorts by expiry date' do
    travel_to(morning) do
      create(:food, organization:, name: 'Later', valid_until: Time.utc(2026, 11, 4, 15, 0))
      create(:beer, organization:, name: 'Sooner', valid_until: Time.utc(2026, 11, 2, 1, 0))

      expect(list.pluck(:name)).to eq(%w[Sooner Later])
    end
  end
end
