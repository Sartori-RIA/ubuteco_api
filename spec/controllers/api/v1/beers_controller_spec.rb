# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BeersController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:beer_styles) { create_list(:beer_style, 10) }
  let!(:makers) { create_list(:maker, 10, organization: organization) }
  let!(:beers) do
    create_list(:beer, 10,
                organization: organization,
                beer_style: beer_styles.sample,
                maker: makers.sample)
  end

  before do
    @beer_styles = create_list(:beer_style, 10)
    @beers = create_list(:beer, 10, beer_style: @beer_styles.sample)
  end

  describe '#GET /api/beers' do
    it 'requests all beers' do
      get api_v1_beers_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/beers/:id' do
    it 'requests beer by id' do
      get api_v1_beer_path(beers.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/beers/search' do
    it 'searches beers' do
      get search_api_v1_beers_path, params: { q: 'tralala' }, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/beers' do
    it 'creates a beer' do
      attributes = attributes_for(:beer).merge(
        maker_id: makers.sample.id,
        beer_style_id: beer_styles.sample.id,
        organization_id: organization.id
      )
      post api_v1_beers_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_beers_path, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/beers/:id' do
    let!(:beer) { beers.sample }

    it 'updates a beer' do
      beer.name = 'editado'
      put api_v1_beer_path(beer.id), params: beer.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      beer.name = ''
      put api_v1_beer_path(beer.id), params: beer.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/beers/:id' do
    it 'deletes beer' do
      delete api_v1_beer_path(beers.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
