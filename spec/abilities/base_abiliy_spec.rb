# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Abilities::BaseAbility, type: :ability do
  describe 'abilities' do
    subject { described_class.new }

    context 'when is an public' do
      context 'can' do
        it { is_expected.to be_able_to(:read, BeerStyle.new) }
        it { is_expected.to be_able_to(:read, WineStyle.new) }
      end
    end
  end
end
