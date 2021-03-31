require 'swagger_helper'

RSpec.describe 'api/v1/orders/{order_id}/items', type: :request do
  path 'api/v1/orders/{order_id}/items' do
    get 'All Wine Styles' do
      tags 'All Wine Styles'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    post 'Create a Wine Style' do
      tags 'Create Wine Style'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    put 'Update a Wine Style' do
      tags 'Update Wine Style'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
    delete 'Destroy a Wine Style' do
      tags 'Destroy Wine Style'
      consumes 'application/json'
      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
