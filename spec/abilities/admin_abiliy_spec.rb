require 'rails_helper'

RSpec.describe Abilities::AdminAbility, type: :ability do
  describe "abilities" do

    before :all do
      @organization = create :organization
      @admin = @organization.user
      @admin.update(organization: @organization)
    end

    subject { Abilities::AdminAbility.new(user: @admin, params: {}) }

    context "when is an admin" do
      context 'can' do
        it { is_expected.to be_able_to(:manage, User.new) }
        it { is_expected.to be_able_to(:manage, @admin) }
        it { is_expected.to be_able_to(:read, Theme.new) }
        it { is_expected.to be_able_to(:update, Theme.new) }
        it { is_expected.to be_able_to(:manage, Organization.new) }
        it { is_expected.to be_able_to(:manage, Beer.new) }
        it { is_expected.to be_able_to(:manage, DishIngredient.new) }
        it { is_expected.to be_able_to(:manage, Dish.new) }
        it { is_expected.to be_able_to(:manage, Drink.new) }
        it { is_expected.to be_able_to(:manage, Food.new) }
        it { is_expected.to be_able_to(:manage, Maker.new) }
        it { is_expected.to be_able_to(:manage, Table.new) }
        it { is_expected.to be_able_to(:manage, Wine.new) }
        it { is_expected.to be_able_to(:manage, Order.new) }
        it { is_expected.to be_able_to(:manage, OrderItem.new) }
      end
    end
  end
end
