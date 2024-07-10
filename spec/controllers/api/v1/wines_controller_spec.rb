# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::WinesController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:makers) { create_list(:maker, 10, organization: organization) }
  let!(:wine_styles) { create_list(:wine_style, 10) }
  let!(:wines) do
    create_list(:wine, 10, organization: organization,
                           wine_style: wine_styles.sample,
                           maker: makers.sample)
  end

  describe '#GET /api/wines' do
    it 'requests all wines' do
      get api_v1_wines_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/wines/:id' do
    it 'requests wine by id' do
      get api_v1_wine_path(wines.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/wines' do
    it 'creates a wine' do
      attributes = attributes_for(:wine).merge(
        maker_id: makers.sample.id,
        wine_style_id: wine_styles.sample.id,
        organization_id: organization.id
      )
      post api_v1_wines_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_wines_path, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/wines/:id' do
    let!(:wine) { wines.sample }

    it 'updates a wine' do
      wine.name = 'editado'
      put api_v1_wine_path(wine.id), params: wine.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      wine.name = ''
      put api_v1_wine_path(wine.id), params: wine.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/wines/:id' do
    it 'deletes wine' do
      delete api_v1_wine_path(wines.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
