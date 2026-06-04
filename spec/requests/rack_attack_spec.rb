# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack::Attack throttles", type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }

  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  after do
    Rack::Attack.reset!
    Rack::Attack.enabled = false
  end

  describe "POST /auth/sign_in" do
    it "returns 429 after too many attempts from the same IP" do
      6.times do
        post "/auth/sign_in", params: { email: "unknown@example.com", password: "wrong" }
      end

      expect(response).to have_http_status(:too_many_requests)
      expect(response.parsed_body).to eq(
        "errors" => [{ "code" => "rate_limit_exceeded", "message" => "Retry later" }]
      )
    end
  end

  describe "GET /api/v1/beers with search" do
    it "returns 429 after too many search requests" do
      get "/api/v1/beers", params: { q: "ipa" }, headers: auth_header(admin)

      60.times do
        get "/api/v1/beers", params: { q: "ipa" }, headers: auth_header(admin)
      end

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
