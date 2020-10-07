# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Beer, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:name) }
    it {is_expected.to monetize(:price)}
    it {is_expected.to validate_presence_of(:quantity_stock)}
    it {is_expected.to validate_presence_of(:ibu)}
    it {is_expected.to validate_presence_of(:abv)}
  end

  describe 'associations' do
    it {is_expected.to belong_to(:user)}
    it {is_expected.to belong_to(:maker)}
    it {is_expected.to belong_to(:beer_style)}
  end
end
