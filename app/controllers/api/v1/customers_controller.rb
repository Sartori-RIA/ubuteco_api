# frozen_string_literal: true

module Api
  class V1::CustomersController < ApplicationController
    load_and_authorize_resource class: User

    def index
      @customers = paginate @customers.order(name: :asc), include: [:role]
    end
  end
end
