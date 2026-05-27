# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Abilities::CustomerAbility, type: :ability do
  describe 'abilities' do
    subject do
      described_class.new(
        user: @user,
        params: { order_id: @order.id, organization_id: @organization.id },
        controller_name: 'Api::V1::Users'
      )
    end

    before :all do
      @organization = create(:organization)
      @user = create(:user, :customer)
      @order = create(:order, :with_items, organization: @organization, user: @user)
      @beer = build(:beer, organization: @organization)
      @other_beer = build(:beer, organization: create(:organization))
    end

    context 'when is an customer' do
      context 'can' do
        it { is_expected.to be_able_to(:manage, @user) }
        it { is_expected.to be_able_to(:read, @beer) }
        it { is_expected.not_to be_able_to(:read, @other_beer) }
        it { is_expected.to be_able_to(:read, build(:dish, organization: @organization)) }
        it { is_expected.to be_able_to(:read, build(:drink, organization: @organization)) }
        it { is_expected.to be_able_to(:read, build(:food, organization: @organization)) }
        it { is_expected.to be_able_to(:read, build(:maker, organization: @organization)) }
        it { is_expected.to be_able_to(:read, build(:table, organization: @organization)) }
        it { is_expected.to be_able_to(:read, build(:wine, organization: @organization)) }
        it { is_expected.to be_able_to(:create, @order) }
        it { is_expected.to be_able_to(:read, @order) }
        it { is_expected.to be_able_to(:update, @order) }
        it { is_expected.to be_able_to(:destroy, @order) }
        it { is_expected.to be_able_to(:read, @order.order_items.sample) }
        it { is_expected.to be_able_to(:update, @order.order_items.sample) }
        it { is_expected.to be_able_to(:create, @order.order_items.sample) }
        it { is_expected.to be_able_to(:edit, @order.order_items.sample) }
        it { is_expected.to be_able_to(:destroy, @order.order_items.sample) }

        context 'in users controller' do
          subject do
            described_class.new(user: @user, params: { order_id: @order.id }, controller_name: 'Api::V1::Users')
          end

          it { is_expected.to be_able_to(:read, @user) }
          it { is_expected.to be_able_to(:update, @user) }
        end
      end
    end
  end
end
