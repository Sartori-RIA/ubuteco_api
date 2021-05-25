require 'rails_helper'

RSpec.describe Abilities::SuperAdminAbility, type: :ability do
  describe "abilities" do
    before :all do
      @organization = create(:organization)
      @user = @organization.user
      @order = create(:order, :open, :with_items, organization: @organization)
      @table = create(:table, organization: @organization)
      @wine = create(:wine, organization: @organization)
      @beer = create(:beer, organization: @organization)
      @dish = create(:dish, organization: @organization)
      @drink = create(:drink, organization: @organization)
      @food = create(:food, organization: @organization)
      @maker = create(:maker, organization: @organization)
    end

    before :all do
      @organization = create(:organization)
      @user = @organization.user
      @order = create(:order, :open, :with_items, organization: @organization)
      @table = create(:table, organization: @organization)
      @wine = create(:wine, organization: @organization)
      @beer = create(:beer, organization: @organization)
      @dish = create(:dish, organization: @organization)
      @drink = create(:drink, organization: @organization)
      @food = create(:food, organization: @organization)
      @maker = create(:maker, organization: @organization)
    end

    subject { described_class.new(user: @user, params: { id: @order.id }, controller_name: 'Api::V1::Organizations::Users') }

    context "when is an super admin" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, Beer.new) }
        it { is_expected.to be_able_to(:manage, Role.new) }
        it { is_expected.to be_able_to(:read, @organization.theme) }
        it { is_expected.to be_able_to(:update, @organization.theme) }
        it { is_expected.to be_able_to(:manage, User.new) }
        it { is_expected.to be_able_to(:manage, Wine.new) }
        it { is_expected.to be_able_to(:manage, WineStyle.new) }
        it { is_expected.to be_able_to(:manage, BeerStyle.new) }
        it { is_expected.to be_able_to(:manage, Dish.new) }
        it { is_expected.to be_able_to(:manage, DishIngredient.new) }
        it { is_expected.to be_able_to(:manage, Drink.new) }
        it { is_expected.to be_able_to(:manage, Food.new) }
        it { is_expected.to be_able_to(:manage, Maker.new) }
        it { is_expected.to be_able_to(:manage, Table.new) }
        it { is_expected.to be_able_to(:create, @order) }
        it { is_expected.to be_able_to(:read, @order) }
        it { is_expected.to be_able_to(:update, @order) }
        it { is_expected.to be_able_to(:destroy, @order) }
        it { is_expected.to be_able_to(:read, @order.order_items.sample) }
        it { is_expected.to be_able_to(:create, @order.order_items.sample) }
        it { is_expected.to be_able_to(:update, @order.order_items.sample) }
        it { is_expected.to be_able_to(:destroy, @order.order_items.sample) }
      end
    end
  end
end
