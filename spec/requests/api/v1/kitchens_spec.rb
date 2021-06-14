require 'swagger_helper'

RSpec.describe Api::V1::KitchensController, type: :request do
  before :all do
    @organization = create(:organization)
    @admin = @organization.user
    @kitchen = create(:user, :kitchen, organization: @organization)
    @orders = create_list(:order, 10, :with_dish, organization: @organization)
  end

  path '/api/v1/kitchens' do
    get 'All Dishes to make' do
      tags 'Kitchen'
      security [Bearer: {}]
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@kitchen)['Authorization'] }
        schema '$ref' => '#/components/schemas/kitchen_items'
        run_test!
      end
    end
  end
  path '/api/v1/kitchens/{id}' do
    put 'Update dish preparation statuses' do
      tags 'Kitchen'
      security [Bearer: {}]
      parameter name: :id, in: :path, type: :string
      parameter name: :params, in: :body, type: :object, schema: { '$ref' => '#/components/schemas/edit_order_item' }
      response 200, 'Ok' do
        let(:'Authorization') { auth_header(@kitchen)['Authorization'] }
        let(:id) { @orders.sample.order_items.sample.id }
        let(:params) { attributes_for(:order_item) }
        schema '$ref' => '#/components/schemas/kitchen_item'
        run_test!
      end
      response 422, 'Invalid request' do
        let(:'Authorization') { auth_header(@kitchen)['Authorization'] }
        let(:id) { @orders.sample.order_items.sample.id }
        let(:params) { { item: nil } }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end
  end
end
