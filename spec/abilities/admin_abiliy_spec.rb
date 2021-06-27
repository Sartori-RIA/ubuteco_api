# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Abilities::AdminAbility, type: :ability do
  describe 'abilities' do
    subject { described_class.new(user: @admin, params: { order_id: @order.id }, controller_name: 'Api::V1::Kitchens') }

    before :all do
      @organization = create(:organization)
      @admin = @organization.user
      @order = create(:order, :open, :with_items, organization: @organization)
      @table = build(:table, organization: @organization)
      @wine = build(:wine, organization: @organization)
      @beer = build(:beer, organization: @organization)
      @drink = build(:drink, organization: @organization)
      @food = build(:food, organization: @organization)
      @maker = build(:maker, organization: @organization)
      @dish = build(:dish, organization: @organization)
      @user = build(:user, organization: @organization)
      @customer = build(:user, :customer)
      @dish_ingredient = build(:dish_ingredient, food: @food, dish: @dish)
    end

    context 'when is an admin' do
      context 'can' do
        it { is_expected.to be_able_to(:read, @organization.theme) }
        it { is_expected.to be_able_to(:update, @organization.theme) }
        it { is_expected.to be_able_to(:manage, @organization) }
        it { is_expected.to be_able_to(:manage, @beer) }
        it { is_expected.to be_able_to(:manage, @dish_ingredient) }
        it { is_expected.to be_able_to(:manage, @dish) }
        it { is_expected.to be_able_to(:manage, @drink) }
        it { is_expected.to be_able_to(:manage, @food) }
        it { is_expected.to be_able_to(:manage, @maker) }
        it { is_expected.to be_able_to(:manage, @table) }
        it { is_expected.to be_able_to(:manage, @wine) }
        it { is_expected.to be_able_to(:create, @order) }
        it { is_expected.to be_able_to(:read, @order) }
        it { is_expected.to be_able_to(:update, @order) }
        it { is_expected.to be_able_to(:destroy, @order) }
        it { is_expected.to be_able_to(:read, @order.order_items.sample) }
        it { is_expected.to be_able_to(:create, @order.order_items.sample) }
        it { is_expected.to be_able_to(:update, @order.order_items.sample) }
        it { is_expected.to be_able_to(:destroy, @order.order_items.sample) }

        context 'in users controller' do
          subject do
            described_class.new(user: @admin, params: { order_id: @order.id }, controller_name: 'Api::V1::Users')
          end

          it { is_expected.to be_able_to(:manage, @user) }
          it { is_expected.to be_able_to(:manage, @admin) }
        end

        context 'in customers controller' do
          subject do
            described_class.new(user: @user, params: { order_id: @order.id }, controller_name: 'Api::V1::Customers')
          end

          it { is_expected.to be_able_to(:read, @customer) }
        end
      end
    end
  end
end
