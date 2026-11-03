# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ai::Assistant::Tool do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:admin) { organization.user }
  let(:admin_ability) do
    Abilities::AdminAbility.new(
      user: admin,
      params: {},
      controller_name: 'Api::V1::Assistant::Conversations'
    )
  end

  def execute(tool, ability: admin_ability, org: organization, args: {})
    tool.execute(ability:, organization: org, user: admin, args:)
  end

  it 'hides low stock from a waiter' do
    waiter = create(:user, :waiter, organization:)
    ability = Abilities::WaiterAbility.new(
      user: waiter,
      params: {},
      controller_name: 'Api::V1::Assistant::Conversations'
    )

    result = Ai::Assistant::Tools::LowStock.execute(
      ability:, organization:, user: waiter, args: {}
    )

    expect(result).to eq(error: 'not_allowed')
  end

  it 'does not include another organization in low stock' do
    other = create(:organization)
    create(:beer, organization: other, name: 'SecretBeer', quantity_stock: 0)
    create(:beer, organization:, name: 'MineBeer', quantity_stock: 0)

    names = execute(Ai::Assistant::Tools::LowStock).fetch(:items).pluck(:name)

    expect(names).to include('MineBeer')
    expect(names).not_to include('SecretBeer')
  end

  it 'returns sales, kitchen, and top products for this organization' do
    summary = execute(Ai::Assistant::Tools::SalesSummary, args: { from: '2026-11-01', to: '2026-11-02' })
    series = execute(Ai::Assistant::Tools::SalesSeries, args: { from: '2026-11-01', to: '2026-11-02', metric: 'orders' })
    kitchen = execute(Ai::Assistant::Tools::KitchenMetrics, args: { from: '2026-11-01', to: '2026-11-02' })
    top = execute(Ai::Assistant::Tools::TopProducts, args: { from: '2026-11-01', to: '2026-11-02', limit: 3 })

    expect(summary[:currency]).to eq(organization.default_currency)
    expect(series[:metric]).to eq('orders')
    expect(kitchen).to include(:open_dish_count)
    expect(top[:items]).to eq([])
  end

  it 'searches only the organization catalog' do
    beer = create(:beer, organization:, name: 'Witbier da casa')
    allow(Catalog::SemanticSearch).to receive(:call).and_return(nil)
    [Beer, Wine, Drink, Food, Dish].each { |model| allow(model).to receive(:search).and_return([]) }
    allow(Beer).to receive(:search).and_return([beer])

    result = execute(Ai::Assistant::Tools::SearchCatalog, args: { query: 'citrus' })

    expect(result[:items].pluck(:name)).to eq(['Witbier da casa'])
    expect(Beer).to have_received(:search).with('citrus', hash_including(where: { organization_id: organization.id }))
  end

  it 'returns an argument error to the model for a bad date' do
    result = execute(Ai::Assistant::Tools::SalesSummary, args: { from: '2026-11-02', to: '2026-11-01' })

    expect(result[:error]).to eq('invalid_arguments')
  end
end
