# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllowlistedJwt, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
