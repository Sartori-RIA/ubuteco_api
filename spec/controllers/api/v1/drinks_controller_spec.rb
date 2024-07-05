# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DrinksController, type: :request do
  let!(:organization) { create(:organization) }
  let!(:admin) { organization.user }
  let!(:makers) { create_list(:maker, 10, organization: organization) }
  let!(:drinks) { create_list(:drink, 10, organization: organization, maker: makers.sample) }

  describe '#GET /api/drinks' do
    it 'requests all drinks' do
      get api_v1_drinks_path, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#GET /api/drinks/:id' do
    it 'requests drink by id' do
      get api_v1_drink_path(drinks.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#POST /api/drinks' do
    it 'creates a drink' do
      attributes = attributes_for(:drink).merge(organization_id: organization.id)
      post api_v1_drinks_path, params: attributes.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:created)
    end

    it 'throws error with invalid params' do
      post api_v1_drinks_path, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#PUT /api/drinks/:id' do
    let!(:drink) { drinks.sample }

    it 'updates a drink' do
      drink.name = 'editado'
      put api_v1_drink_path(drink.id), params: drink.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end

    it 'throws error with invalid params' do
      drink.name = ''
      put api_v1_drink_path(drink.id), params: drink.to_json, headers: auth_header(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#DELETE /api/drinks/:id' do
    it 'deletes drink' do
      delete api_v1_drink_path(drinks.sample.id), headers: auth_header(admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
