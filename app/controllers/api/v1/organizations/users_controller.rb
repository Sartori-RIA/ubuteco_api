# frozen_string_literal: true

module Api
  module V1
    module Organizations
      class UsersController < ApplicationController
        load_and_authorize_resource

        def index
          pagy_render @users.order(name: :asc), [:role]
        end
      end
    end
  end
end
