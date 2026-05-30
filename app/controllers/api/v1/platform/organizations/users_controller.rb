# frozen_string_literal: true

module Api
  module V1
    module Platform
      module Organizations
        class UsersController < BaseController
          load_and_authorize_resource class: User, except: :index

          def index
            authorize! :read, User
            @pagy, @records = pagy_search_authorized(User)
            render 'api/v1/organizations/users/index'
          end
        end
      end
    end
  end
end
