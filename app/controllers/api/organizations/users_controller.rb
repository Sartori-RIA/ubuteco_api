# frozen_string_literal: true

module Api
  module Organizations
    class UsersController < ApplicationController
      load_and_authorize_resource

      def index
        paginate json: @users.order(name: :asc), include: [:role]
      end
    end
  end
end
