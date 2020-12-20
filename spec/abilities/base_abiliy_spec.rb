require 'rails_helper'

RSpec.describe Abilities::BaseAbility do
  describe "abilities" do

    subject { Abilities::BaseAbility.new }

    context "when is an public" do
      it { is_expected.to be_able_to(:read, BeerStyle) }
      it { is_expected.to be_able_to(:read, WineStyle) }
      it { is_expected.to be_able_to(:search, BeerStyle) }
      it { is_expected.to be_able_to(:search, WineStyle) }
    end
  end
end
