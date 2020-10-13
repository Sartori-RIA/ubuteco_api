# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:role) { create(:role_as_restaurant) }

  describe 'validations' do
    it {is_expected.to validate_presence_of(:name)}
    it {is_expected.to validate_presence_of(:email)}
    it {is_expected.to validate_presence_of(:password)}
    it {is_expected.to validate_presence_of(:company_name)}
    it {is_expected.to validate_presence_of(:cnpj)}
  end

  describe 'associations' do
    it {is_expected.to belong_to(:role)}
    it {is_expected.to have_many(:beers)}
    it {is_expected.to have_many(:makers)}
    it {is_expected.to have_many(:drinks)}
    it {is_expected.to have_many(:foods)}
    it {is_expected.to have_many(:orders)}
    it {is_expected.to have_many(:dishes)}
    it {is_expected.to have_many(:tables)}
  end
end
