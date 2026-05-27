# frozen_string_literal: true

module Api
  module V1
    class CustomersController < ApplicationController
      load_and_authorize_resource class: User, except: :index

      def index
        authorize! :read, User
        @pagy, @records = pagy_search_authorized(User)
      end
    end
  end
end
