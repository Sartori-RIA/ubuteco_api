# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Maker, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:country) }
  end

  describe 'associations' do
    it {is_expected.to belong_to(:user)}
  end
end
