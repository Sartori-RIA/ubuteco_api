# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Food, type: :model do
  describe 'validates' do
  end

  describe 'associations' do
    it {is_expected.to belong_to(:user)}
  end
end
