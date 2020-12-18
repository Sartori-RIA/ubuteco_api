# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:role) { create(:admin) }

  describe 'validations' do
    it {is_expected.to validate_presence_of(:name)}
    it {is_expected.to validate_presence_of(:email)}
    it {is_expected.to validate_presence_of(:password)}
  end

  describe 'associations' do
    it {is_expected.to belong_to(:role)}
    it {is_expected.to belong_to(:organization)}
  end
end
