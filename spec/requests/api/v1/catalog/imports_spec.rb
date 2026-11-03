# frozen_string_literal: true

require "swagger_helper"

RSpec.describe Api::V1::Catalog::ImportsController, type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { organization.user }
  let(:Authorization) { auth_header(admin)["Authorization"] }

  before { allow(Catalog::CsvImportJob).to receive(:perform_async) }

  def uploaded(body = "name,price\nSoda,8.00\n")
    file = Tempfile.new(["import", ".csv"])
    file.write(body)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, "text/csv")
  end

  path "/api/v1/catalog/imports" do
    post "Enqueue a catalog import" do
      tags "Catalog imports"
      security [Bearer: {}]
      consumes "multipart/form-data"
      parameter name: :file, in: :formData, type: :file, required: true
      parameter name: :product_type, in: :formData, type: :string, required: true

      response "202", "queued" do
        let(:product_type) { "drink" }
        let(:file) { uploaded }
        let(:drinks_before) { Drink.count }

        run_test! do
          expect(Drink.count).to eq(drinks_before)
          expect(json["status"]).to eq("queued")
        end
      end

      response "409", "already running" do
        let(:product_type) { "drink" }
        let(:file) { uploaded }

        before do
          organization.catalog_imports.create!(
            user: admin, product_type: "drink", status: "queued", enqueued_at: Time.current
          )
        end

        run_test! do
          expect(json["id"]).to be_present
          expect(json["errors"].first["code"]).to eq("import_in_progress")
        end
      end

      response "403", "not an admin" do
        let(:product_type) { "drink" }
        let(:file) { uploaded }
        let(:Authorization) { auth_header(create(:user, :waiter, organization:))["Authorization"] }

        run_test!
      end

      response "422", "invalid csv" do
        let(:product_type) { "drink" }
        let(:file) { uploaded("nome,preco\nA,1\n") }

        run_test! do
          expect(json["errors"].first["code"]).to eq("invalid_csv")
          expect(CatalogImport.count).to eq(0)
        end
      end
    end

    get "List catalog imports" do
      tags "Catalog imports"
      security [Bearer: {}]

      response "200", "ok" do
        before do
          organization.catalog_imports.create!(
            user: admin, product_type: "food", status: "completed", enqueued_at: Time.current
          )
        end

        run_test! do
          expect(json.first["product_type"]).to eq("food")
        end
      end
    end
  end

  path "/api/v1/catalog/imports/{id}" do
    get "Show a catalog import" do
      tags "Catalog imports"
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :integer

      response "200", "queued without a runtime history" do
        let(:id) do
          organization.catalog_imports.create!(
            user: admin, product_type: "beer", status: "queued", enqueued_at: Time.current, row_log: []
          ).id
        end

        run_test! do
          expect(json["estimated_start_at"]).to be_nil
          expect(json["row_log"]).to eq([])
        end
      end
    end
  end

  describe "GET /api/v1/catalog/imports/:id" do
    it "hides another organization" do
      import = organization.catalog_imports.create!(
        user: admin, product_type: "beer", status: "queued", enqueued_at: Time.current
      )
      other = create(:organization)

      get "/api/v1/catalog/imports/#{import.id}", headers: auth_header(other.user)

      expect(response).to have_http_status(:not_found)
    end

    it "estimates a start time from a finished import" do
      organization.catalog_imports.create!(
        user: admin,
        product_type: "beer",
        status: "completed",
        enqueued_at: 2.minutes.ago,
        started_at: 1.minute.ago,
        finished_at: Time.current
      )
      queued = organization.catalog_imports.create!(
        user: admin, product_type: "beer", status: "queued", enqueued_at: Time.current
      )

      get "/api/v1/catalog/imports/#{queued.id}", headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      expect(json["estimated_start_at"]).to be_present
    end
  end

  describe "authorization" do
    it "rejects cash register and super admin" do
      cash = create(:user, :cash_register, organization:)
      super_admin = create(:user, :super_admin, organization:)
      params = { product_type: "drink", file: uploaded }

      post "/api/v1/catalog/imports", params:, headers: auth_header(cash).except("Content-Type")
      expect(response).to have_http_status(:forbidden)

      post "/api/v1/catalog/imports", params:, headers: auth_header(super_admin).except("Content-Type")
      expect(response).to have_http_status(:forbidden)
    end
  end

  path "/api/v1/catalog/imports/template" do
    get "Download an English CSV template" do
      tags "Catalog imports"
      security [Bearer: {}]
      produces "text/csv"
      parameter name: :product_type, in: :query, type: :string, required: true

      response "200", "template" do
        let(:product_type) { "dish" }

        run_test! do
          expect(response.body).to include("ingredients")
        end
      end
    end
  end

  describe "GET /api/v1/catalog/imports/template" do
    it "returns an English template that parses" do
      get "/api/v1/catalog/imports/template", params: { product_type: "dish" }, headers: auth_header(admin)

      expect(response).to have_http_status(:ok)
      table = Catalog::CsvImport::Table.parse(StringIO.new(response.body), product_type: "dish")
      expect(table.rows.first["ingredients"]).to include("|")
    end
  end

  def json
    response.parsed_body
  end
end
