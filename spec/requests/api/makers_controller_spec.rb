# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MakersController, type: :request do
  before :each do
    @organization = create :organization
    @admin = @organization.user
    @admin.update(organization: @organization)
    @makers = create_list :maker, 10, organization: @organization
  end

  describe '#GET /api/makers' do
    it 'should request all beer' do
      get api_makers_path, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/makers/:id' do
    it 'should request maker by id' do
      get api_maker_path(@makers.sample.id), headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/makers/search' do
    it 'should search makers' do
      get search_api_makers_path, params: { q: 'tralala' }, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/makers' do
    it 'should create a maker' do
      attributes = attributes_for(:maker).except(:user)
      post api_makers_path, params: attributes.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_makers_path, headers: auth_header(@admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/makers/:id' do
    let!(:maker) { @makers.sample }
    it 'should update a maker' do
      maker.name = 'editado'
      put api_maker_path(maker.id), params: maker.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      maker.name = ''
      put api_maker_path(maker.id), params: maker.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/makers/:id' do
    it 'should delete maker' do
      delete api_maker_path(@makers.sample.id), headers: auth_header(@admin)
      expect(response).to have_http_status(204)
    end
  end
end
