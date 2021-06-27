# frozen_string_literal: true

module Api
  module V1
    module Organizations
      class UsersController < ApplicationController
        load_and_authorize_resource

        def index
          @users = paginate @users.order(name: :asc), include: [:role]
        end
      end
    end
  end
end
