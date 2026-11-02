# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Product intake API', type: :request do
  let(:organization) { create(:organization, ai_enabled: true) }
  let(:admin) { organization.user }
  let(:Authorization) { auth_header(admin)['Authorization'] }
  let(:xml_path) { Rails.root.join('spec/fixtures/files/nfe_sample.xml') }

  path '/api/v1/inventory/intake/nfe' do
    post 'Parse an NF-e XML into stock lines' do
      tags 'Inventory'
      security [Bearer: {}]
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :file, in: :formData, type: :file, required: true

      response '200', 'Ok' do
        let(:file) { Rack::Test::UploadedFile.new(xml_path, 'application/xml') }

        run_test!
      end
    end
  end

  path '/api/v1/inventory/intake/document' do
    post 'Draft stock lines from an invoice photo or PDF' do
      tags 'Inventory'
      security [Bearer: {}]
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :file, in: :formData, type: :file, required: true

      response '200', 'Ok' do
        let(:file) do
          path = Rails.root.join('spec/fixtures/files/label.png')
          File.binwrite(path, Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='))
          Rack::Test::UploadedFile.new(path, 'image/png')
        end

        before do
          ENV['AI_ENABLED'] = '1'
          Ai::FakeClient.enqueue(
            Ai.result(text: '[{"description":"Cerveja Lager","ean":null,"quantity":4,"unit":"UN","unit_cost_cents":800}]')
          )
        end

        after { ENV.delete('AI_ENABLED') }

        run_test!
      end
    end
  end

  path '/api/v1/catalog/intake/label' do
    post 'Draft a product from a label photo' do
      tags 'Catalog'
      security [Bearer: {}]
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :file, in: :formData, type: :file, required: true
      parameter name: :product_type, in: :formData, type: :string, required: true

      response '200', 'Ok' do
        let(:product_type) { 'beer' }
        let(:file) do
          path = Rails.root.join('spec/fixtures/files/label.png')
          File.binwrite(path, Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='))
          Rack::Test::UploadedFile.new(path, 'image/png')
        end

        before do
          ENV['AI_ENABLED'] = '1'
          Ai::FakeClient.enqueue(
            Ai.result(text: '{"name":"Loba IPA","maker":null,"style":null,"abv":6.5,"ibu":40,"description":""}')
          )
        end

        after { ENV.delete('AI_ENABLED') }

        run_test!
      end
    end
  end
end
