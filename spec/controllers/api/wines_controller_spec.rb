# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::WinesController, type: :request do

  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:makers) { create_list(:maker, 10, organization: organization) }
  let!(:wine_styles) { create_list(:wine_style, 10) }
  let!(:wines) { create_list(:wine, 10, organization: organization,
                             wine_style: wine_styles.sample,
                             maker: makers.sample) }

  describe '#GET /api/wines' do
    it 'should request all wines' do
      get api_wines_path, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/wines/:id' do
    it 'should request wine by id' do
      get api_wine_path(wines.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/wines/search' do
    it 'should search wines' do
      get search_api_wines_path, params: { q: 'tralala' }, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/wines' do
    it 'should create a wine' do
      attributes = attributes_for(:wine).merge(
        maker_id: makers.sample.id,
        wine_style_id: wine_styles.sample.id,
        organization_id: organization.id
      )
      post api_wines_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_wines_path, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/wines/:id' do
    let!(:wine) { wines.sample }
    it 'should update a wine' do
      wine.name = 'editado'
      put api_wine_path(wine.id), params: wine.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      wine.name = ''
      put api_wine_path(wine.id), params: wine.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/wines/:id' do
    it 'should delete wine' do
      delete api_wine_path(wines.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(204)
    end
  end
end
