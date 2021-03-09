# frozen_string_literal: true

module Api
  class CustomersController < ApplicationController
    load_and_authorize_resource class: User

    def index
      paginate json: @customers.order(name: :asc), include: [:role]
    end
  end
end
