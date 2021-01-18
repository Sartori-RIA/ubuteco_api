require 'rails_helper'

RSpec.describe Abilities::AdminAbility, type: :ability do
  describe "abilities" do

    before :all do
      @organization = create :organization
      @admin = @organization.user
      @admin.update(organization: @organization)
    end

    subject { Abilities::AdminAbility.new(user: @admin, params: {}) }

    context "when is an public" do
      it { is_expected.to be_able_to(:manage, User) }
      it { is_expected.to be_able_to(:manage, @admin) }
      it { is_expected.to be_able_to(:read, Theme) }
      it { is_expected.to be_able_to(:update, Theme) }
      it { is_expected.to be_able_to(:manage, Organization) }
      it { is_expected.to be_able_to(:manage, Beer) }
      it { is_expected.to be_able_to(:search, Beer) }
      it { is_expected.to be_able_to(:manage, DishIngredient) }
      it { is_expected.to be_able_to(:manage, Dish) }
      it { is_expected.to be_able_to(:search, Dish) }
      it { is_expected.to be_able_to(:manage, Drink) }
      it { is_expected.to be_able_to(:search, Drink) }
      it { is_expected.to be_able_to(:manage, Food) }
      it { is_expected.to be_able_to(:search, Food) }
      it { is_expected.to be_able_to(:manage, Maker) }
      it { is_expected.to be_able_to(:search, Maker) }
      it { is_expected.to be_able_to(:manage, Table) }
      it { is_expected.to be_able_to(:search, Table) }
      it { is_expected.to be_able_to(:manage, Wine) }
      it { is_expected.to be_able_to(:search, Wine) }
      it { is_expected.to be_able_to(:create, Order) }
      it { is_expected.to be_able_to(:create, Order) }
      it { is_expected.to be_able_to(:update, Order) }
      it { is_expected.to be_able_to(:destroy, Order) }
      it { is_expected.to be_able_to(:manage, OrderItem) }
    end
  end
end
