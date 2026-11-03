# frozen_string_literal: true

module Api
  module V1
    module Assistant
      class ConversationsController < ApplicationController
        MAX_CONTENT = 4_000

        before_action :require_assistant!
        rescue_from ActiveRecord::RecordNotFound, with: :missing_conversation

        def index
          conversations = own_conversations.order(updated_at: :desc).limit(50)
          render json: { data: conversations.map { |conversation| conversation_json(conversation) } }
        end

        def show
          conversation = find_own!
          render json: conversation_json(conversation).merge(messages: visible_messages(conversation))
        end

        def create
          conversation = own_conversations.create!(title: params[:title].to_s.strip.presence)
          render json: conversation_json(conversation), status: :created
        end

        def destroy
          find_own!.destroy!
          head :no_content
        end

        def messages
          conversation = find_own!
          text = params[:content].to_s.strip
          return render_content_error(:blank) if text.blank?
          return render_content_error(:too_long) if text.length > MAX_CONTENT

          conversation.update!(title: text.truncate(80)) if conversation.title.blank?
          conversation.ai_messages.create!(role: 'user', content: { text: })
          reply = Ai::Assistant::Run.call(
            conversation:,
            user: current_user,
            organization: Current.organization,
            ability: current_ability
          )
          message = conversation.ai_messages.where(role: 'assistant').order(:id).last
          render json: { message: message_json(message, reply) }, status: :created
        end

        private

        def require_assistant!
          authorize! :use, :assistant
          raise Ai::DisabledError unless Ai.enabled_for?(Current.organization)
        end

        def own_conversations
          AiConversation.where(organization_id: Current.organization.id, user_id: current_user.id)
        end

        def find_own!
          own_conversations.find(params[:id])
        end

        def visible_messages(conversation)
          conversation.ai_messages.where(role: %w[user assistant]).order(:id).map { |message| message_json(message) }
        end

        def conversation_json(conversation)
          {
            id: conversation.id,
            title: conversation.title,
            updated_at: conversation.updated_at.iso8601
          }
        end

        def message_json(message, text = nil)
          {
            id: message.id,
            role: message.role,
            text: text || message.content['text'].to_s,
            created_at: message.created_at.iso8601
          }
        end

        def missing_conversation
          head :not_found
        end

        def render_content_error(key)
          render_api_errors(
            [{ code: 'validation_error', field: 'content', message: I18n.t("assistant.errors.#{key}") }],
            status: :unprocessable_content
          )
        end
      end
    end
  end
end
