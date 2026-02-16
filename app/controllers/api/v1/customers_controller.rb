# frozen_string_literal: true

module Api
  module V1
    class CustomersController < ApplicationController
      load_and_authorize_resource class: User

      def index
        pagy_render @customers.includes(:role).order(name: :asc)
      end
    end
  end
end
