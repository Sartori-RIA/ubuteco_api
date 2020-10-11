# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::BeersController, type: :request do
  let!(:user) { create(:user) }
  let!(:beer_styles) { create_list(:beer_style, 10, user: user) }
  let!(:makers) { create_list(:maker, 10, user: user) }
  let!(:beers) { create_list(:beer, 10, user: user) }

  describe '#GET /api/beers' do
    it 'should request all beers' do
      get api_beers_path, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/beers/:id' do
    it 'should request beer by id' do
      get api_beer_path(beers.sample.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/beers/search' do
    it 'should search beers' do
      get search_api_beers_path, params: {q: 'tralala'}, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/beers' do
    it 'should create a beer' do
      attributes = attributes_for(:beer).merge(
        maker_id: makers.sample.id,
        beer_style_id: beer_styles.sample.id
      )
      post api_beers_path, params: attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_beers_path, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/beers/:id' do
    let!(:beer) { beers.sample }
    it 'should update a beer' do
      beer.name = 'editado'
      put api_beer_path(beer.id), params: beer.to_json, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      beer.name = ''
      put api_beer_path(beer.id), params: beer.to_json, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/beers/:id' do
    it 'should delete beer' do
      delete api_beer_path(beers.sample.id), headers: auth_header(user)
      expect(response).to have_http_status(204)
    end
  end
end
