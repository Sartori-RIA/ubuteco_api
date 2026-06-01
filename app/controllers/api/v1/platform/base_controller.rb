# frozen_string_literal: true

module Api
  module V1
    module Platform
      class BaseController < ApplicationController
        before_action :require_platform_access!

        private

        def require_platform_access!
          return if current_user&.role&.name == 'SUPER_ADMIN'

          head :forbidden
        end
      end
    end
  end
end
