# frozen_string_literal: true

module Api
  module V1
    class CustomersController < ApplicationController
      load_and_authorize_resource class: User

      def index
        @customers = paginate @customers.order(name: :asc), include: [:role]
      end
    end
  end
end
