# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::TablesController, type: :request do
  before :all do
    @organization = create :organization
    @admin = @organization.user
    @admin.update(organization: @organization)
    @tables = create_list :table, 10, organization: @organization
  end

  describe '#GET /api/tables' do
    it 'should request all tables' do
      get api_tables_path, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/tables/:id' do
    it 'should request table by id' do
      get api_table_path(@tables.sample.id), headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#GET /api/tables/search' do
    it 'should search tables' do
      get search_api_tables_path, params: { q: 'tralala' }, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
  end

  describe '#POST /api/tables' do
    it 'should create a table' do
      attributes = attributes_for(:table).except(:user)
      post api_tables_path, params: attributes.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(201)
    end
    it 'should throw error with invalid params' do
      post api_tables_path, headers: auth_header(@admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#PUT /api/tables/:id' do
    let!(:table) { @tables.sample }
    it 'should update a table' do
      table.name = 'editado'
      put api_table_path(table.id), params: table.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(200)
    end
    it 'should throw error with invalid params' do
      table.name = ''
      put api_table_path(table.id), params: table.to_json, headers: auth_header(@admin)
      expect(response).to have_http_status(422)
    end
  end

  describe '#DELETE /api/tables/:id' do
    it 'should delete table' do
      delete api_table_path(@tables.sample.id), headers: auth_header(@admin)
      expect(response).to have_http_status(204)
    end
  end
end
