# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::EmbeddingText do
  let(:organization) { create(:organization) }

  it 'joins the fields that describe a beer' do
    beer = create(:beer, organization:, name: 'Witbier', description: 'casca de laranja')

    text = described_class.for(beer)

    expect(text).to include('Witbier')
    expect(text).to include('casca de laranja')
    expect(text).to include(beer.beer_style.name)
    expect(text).to include(beer.maker.name)
  end

  it 'includes dish ingredient names' do
    food = create(:food, organization:, name: 'Limão')
    dish = create(:dish, organization:, name: 'Caipirinha')
    create(:dish_ingredient, dish:, food:)

    expect(described_class.for(dish.reload)).to include("Caipirinha\nLimão")
  end

  it 'is stable for the same text' do
    beer = create(:beer, organization:)

    expect(described_class.digest(beer)).to eq(described_class.digest(beer.reload))
  end
end
