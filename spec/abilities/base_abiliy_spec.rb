require 'rails_helper'

RSpec.describe Abilities::BaseAbility, type: :ability do
  describe "abilities" do

    subject { Abilities::BaseAbility.new }

    context "when is an public" do
      context 'can' do
        it { is_expected.to be_able_to(:read, BeerStyle.new) }
        it { is_expected.to be_able_to(:read, WineStyle.new) }
        it { is_expected.to be_able_to(:search, BeerStyle.new) }
        it { is_expected.to be_able_to(:search, WineStyle.new) }
      end
    end
  end
end
