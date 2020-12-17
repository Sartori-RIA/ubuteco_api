require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe "associations" do
    it {is_expected.to have_many(:beers)}
    it {is_expected.to have_many(:makers)}
    it {is_expected.to have_many(:drinks)}
    it {is_expected.to have_many(:foods)}
    it {is_expected.to have_many(:orders)}
    it {is_expected.to have_many(:dishes)}
    it {is_expected.to have_many(:tables)}
    it {is_expected.to have_many(:users)}
  end
end
