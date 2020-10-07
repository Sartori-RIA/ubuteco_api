# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wine, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:abv) }
    it { is_expected.to validate_presence_of(:quantity_stock) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:vintage_wine) }
    it { is_expected.to validate_presence_of(:visual) }
    it { is_expected.to validate_presence_of(:ripening) }
    it { is_expected.to validate_presence_of(:grapes) }
    it { is_expected.to monetize(:price) }
  end

  describe 'associations' do
    it {is_expected.to belong_to(:user)}
    it {is_expected.to belong_to(:maker)}
    it {is_expected.to belong_to(:wine_style)}
  end
end
