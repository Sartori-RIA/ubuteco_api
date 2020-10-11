# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::BeerStylesController, type: :request do
  let!(:user) { create(:user) }
  let!(:beer_styles) { create_list(:beer_style, 10, user: user) }

  describe '#GET /api/beer_styles' do
    it 'should request all beer styles' do
      get api_beer_styles_path, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/beer_styles/:id' do
    it 'should request beer style by id' do
      get api_beer_style_path(beer_styles.sample.id), headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/beer_styles' do
    it 'should create a beer style' do
      attributes = attributes_for(:beer_style).except(:user)
      post api_beer_styles_path, params: attributes.to_json, headers: auth_header(user)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_beer_styles_path, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/beer_styles/:id' do
    let!(:beer_style) { beer_styles.sample}
    it 'should update a beer style' do
      beer_style.name = 'editado'
      put api_beer_style_path(beer_style.id), params: beer_style.to_json, headers: auth_header(user)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      beer_style.name = ''
      put api_beer_style_path(beer_style.id), params: beer_style.to_json, headers: auth_header(user)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/beer_styles/:id' do
    it 'should delete beer style' do
      delete api_beer_style_path(beer_styles.sample.id), headers: auth_header(user)
      expect(response).to have_http_status(204)
    end
  end
end
