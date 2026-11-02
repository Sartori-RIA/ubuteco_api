# frozen_string_literal: true

module Api
  module V1
    module Platform
      class ImpersonationsController < BaseController
        def index
          render json: { data: SupportSession.recent.map(&:as_list_json) }
        end

        def create
          result = Support::StartSession.new(
            actor: current_user,
            user_id: params[:user_id],
            reason: params[:reason]
          ).call
          if result.ok?
            render json: result.payload, status: :created
          else
            render_i18n_api_error(result.error, status: result.status)
          end
        end

        def destroy
          session = SupportSession.find_by(id: params[:id])
          return head :not_found if session.nil?

          session.finish!
          head :no_content
        end
      end
    end
  end
end
