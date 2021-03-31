# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BeerStylesController, type: :request do

  let!(:super_admin) { create(:user_super_admin) }
  let!(:beer_styles) { create_list(:beer_style, 10) }
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }

  describe '#GET /api/beer_styles' do
    it 'should request all beer styles' do
      get api_v1_beer_styles_path, headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/beer_styles/:id' do
    it 'should request beer style by id' do
      get api_v1_beer_style_path(beer_styles.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/beer_styles/check/style' do
    it 'should return :ok status to style in use' do
      get check_style_api_v1_beer_styles_path, params: { q: beer_styles.sample.name }, headers: auth_header(super_admin)
      expect(response).to have_http_status(:ok)
    end
    it 'should return :no_content status to style available' do
      get check_style_api_v1_beer_styles_path, params: { q: Faker::Beer.unique.style }, headers: auth_header(super_admin)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe '#POST /api/beer_styles' do
    it 'should create a beer style' do
      attributes = attributes_for(:beer_style)
      post api_v1_beer_styles_path, params: attributes.to_json, headers: auth_header(super_admin)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_v1_beer_styles_path, headers: auth_header(super_admin)
      expect(response).to have_http_status(422)
    end
    it 'should throw error with invalid params' do
      post api_v1_beer_styles_path, headers: auth_header(admin)
      expect(response).to have_http_status(403)
    end
  end

  describe '#PUT /api/beer_styles/:id' do
    let!(:beer_style) { beer_styles.sample }
    it 'should update a beer style' do
      beer_style.name = 'editado'
      put api_v1_beer_style_path(beer_style.id), params: beer_style.to_json, headers: auth_header(super_admin)
      expect(response).to have_http_status(200)
    end
    it 'should trow forbidden status' do
      beer_style.name = 'editado'
      put api_v1_beer_style_path(beer_style.id), params: beer_style.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(403)
    end
    it 'should throw error with invalid params' do
      beer_style.name = ''
      put api_v1_beer_style_path(beer_style.id), params: beer_style.to_json, headers: auth_header(super_admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/beer_styles/:id' do
    it 'should delete beer style' do
      delete api_v1_beer_style_path(beer_styles.sample.id), headers: auth_header(super_admin)
      expect(response).to have_http_status(204)
    end
    it 'should trow forbidden status' do
      delete api_v1_beer_style_path(beer_styles.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(403)
    end
  end
end
