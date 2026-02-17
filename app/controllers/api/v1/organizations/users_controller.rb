# frozen_string_literal: true

module Api
  module V1
    module Organizations
      class UsersController < ApplicationController
        load_and_authorize_resource

        def index
          search = Beer.pagy_search(params[:q].presence || "*", page: params[:page], per_page: 20)
          @pagy, @records = pagy(:searchkick, search)
        end
      end
    end
  end
end
