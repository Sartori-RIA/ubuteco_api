# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::WineStylesController, type: :request do
  let!(:role_restaurant) { create(:role_as_restaurant) }
  let!(:role_admin) { create(:role_as_admin) }

  let!(:user) { create(:user, role: role_restaurant) }
  let!(:admin) { create(:user, role: role_admin) }

  let!(:wine_styles) { create_list(:wine_style, 10) }

  describe '#GET /api/wine_styles' do
    it 'should request all wine styles' do
      get api_wine_styles_path, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/wine_styles/:id' do
    it 'should request wine style by id' do
      get api_wine_style_path(wine_styles.sample.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/wine_styles' do
    it 'should create a wine style' do
      attributes = attributes_for(:wine_style)
      post api_wine_styles_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_wine_styles_path, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
    it 'should trow forbidden status' do
      post api_wine_styles_path, headers: auth_header(user)
      expect(response).to have_http_status(403)
    end
  end

  describe '#PUT /api/wine_styles/:id' do
    let!(:wine_style) {wine_styles.sample}
    it 'should update a wine style' do
      wine_style.name = 'editado'
      put api_wine_style_path(wine_style.id), params: wine_style.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      wine_style.name = ''
      put api_wine_style_path(wine_style.id), params: wine_style.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(422)
    end
    it 'should trow forbidden status' do
      wine_style.name = 'asdasd'
      put api_wine_style_path(wine_style.id), params: wine_style.to_json, headers: auth_header(user)
      expect(response).to have_http_status(403)
    end
  end

  describe '#DELETE /api/wine_styles/:id' do
    it 'should delete wine style' do
      delete api_wine_style_path(wine_styles.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(204)
    end
    it 'should trow forbidden status' do
      delete api_wine_style_path(wine_styles.sample.id), headers: auth_header(user)
      expect(response).to have_http_status(403)
    end
  end
end
