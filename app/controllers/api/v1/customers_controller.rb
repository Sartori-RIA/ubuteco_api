# frozen_string_literal: true

module Api
  module V1
    class CustomersController < ApplicationController
      load_and_authorize_resource class: User

      def index
        pagy_render @customers.order(name: :asc), [:role]
      end
    end
  end
end
