# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /up", type: :request do
  it "returns ok without authentication" do
    get "/up"

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["status"]).to eq("ok")
    expect(body["redis"]).to eq("skipped")
  end
end
