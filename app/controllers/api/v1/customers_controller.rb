# frozen_string_literal: true

module Api
  module V1
    class CustomersController < ApplicationController
      load_and_authorize_resource class: User

      def index
        search = User.pagy_search(params[:q].presence || "*", page: params[:page], per_page: 20)
        @pagy, @records = pagy(:searchkick, search)
      end
    end
  end
end
