# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Table, type: :model do
  describe 'validates' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:chairs) }
  end

  describe 'associations' do
    it {is_expected.to belong_to(:organization)}
  end
end
