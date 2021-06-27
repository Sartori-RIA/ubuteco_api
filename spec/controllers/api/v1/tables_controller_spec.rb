# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TablesController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:tables) { create_list(:table, 10, organization: organization) }

  describe '#GET /api/tables' do
    it 'requests all tables' do
      get api_v1_tables_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/tables/:id' do
    it 'requests table by id' do
      get api_v1_table_path(tables.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/tables/search' do
    it 'searches tables' do
      get search_api_v1_tables_path, params: { q: 'tralala' }, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/tables' do
    it 'creates a table' do
      attributes = attributes_for(:table).merge(organization_id: organization.id)
      post api_v1_tables_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_tables_path, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/tables/:id' do
    let!(:table) { tables.sample }

    it 'updates a table' do
      table.name = 'editado'
      put api_v1_table_path(table.id), params: table.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      table.name = ''
      put api_v1_table_path(table.id), params: table.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/tables/:id' do
    it 'deletes table' do
      delete api_v1_table_path(tables.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
