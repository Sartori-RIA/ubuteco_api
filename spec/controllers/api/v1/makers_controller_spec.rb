# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MakersController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:makers) { create_list(:maker, 10, organization: organization) }

  describe '#GET /api/makers' do
    it 'requests all beer' do
      get api_v1_makers_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/makers/:id' do
    it 'requests maker by id' do
      get api_v1_maker_path(makers.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/makers' do
    it 'creates a maker' do
      attributes = attributes_for(:maker).merge(organization_id: organization.id)
      post api_v1_makers_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_makers_path, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/makers/:id' do
    let!(:maker) { makers.sample }

    it 'updates a maker' do
      maker.name = 'editado'
      put api_v1_maker_path(maker.id), params: maker.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      maker.name = ''
      put api_v1_maker_path(maker.id), params: maker.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/makers/:id' do
    it 'deletes maker' do
      delete api_v1_maker_path(makers.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
