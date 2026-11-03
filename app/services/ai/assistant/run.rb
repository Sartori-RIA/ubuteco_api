# frozen_string_literal: true

module Ai
  module Assistant
    class Run
      MAX_ROUNDS = 5
      TIMEOUT_SECONDS = 25
      PROMPT = Rails.root.join('app/prompts/assistant/system.md.erb')

      def self.call(conversation:, user:, organization:, ability:)
        new(conversation:, user:, organization:, ability:).call
      end

      def initialize(conversation:, user:, organization:, ability:)
        @conversation = conversation
        @user = user
        @organization = organization
        @ability = ability
      end

      def call
        Timeout.timeout(TIMEOUT_SECONDS) { answer }
      rescue Timeout::Error
        remember(I18n.t('assistant.timeout', locale:))
      end

      private

      attr_reader :conversation, :user, :organization, :ability

      def answer
        messages = provider_messages
        MAX_ROUNDS.times do
          result = complete(messages)
          return remember(result.text.presence || I18n.t('assistant.empty', locale:), result) if result.tool_calls.blank?

          messages = append_round(messages, result)
        end
        remember(I18n.t('assistant.too_many_tools', locale:))
      end

      def complete(messages)
        Ai::Client.complete(
          feature: Ai::Feature::ASSISTANT,
          tier: :smart,
          system: system_prompt,
          messages:,
          tools: Tool.schemas,
          organization:,
          user:
        )
      end

      def append_round(messages, result)
        persist_assistant(result)
        tool_results = result.tool_calls.map { |call| execute(call) }
        messages + [
          { role: 'assistant', content: assistant_blocks(result) },
          { role: 'user', content: tool_results }
        ]
      end

      def execute(call)
        tool = Tool.find(call.name)
        payload = tool ? tool.execute(ability:, organization:, user:, args: call.input) : { error: 'unknown_tool' }
        conversation.ai_messages.create!(
          role: 'tool',
          tool_name: call.name,
          content: { tool_use_id: call.id, result: payload }
        )
        { type: 'tool_result', tool_use_id: call.id, content: payload.to_json }
      end

      def remember(text, result = nil)
        persist_assistant(result, text)
        text
      end

      def persist_assistant(result, text = nil)
        calls = Array(result&.tool_calls).map { |call| { id: call.id, name: call.name, input: call.input } }
        conversation.ai_messages.create!(
          role: 'assistant',
          content: { text: text || result&.text.to_s, tool_calls: calls },
          usage: usage_hash(result)
        )
      end

      def assistant_blocks(result)
        blocks = []
        blocks << { type: 'text', text: result.text } if result.text.present?
        result.tool_calls.each do |call|
          blocks << { type: 'tool_use', id: call.id, name: call.name, input: call.input || {} }
        end
        blocks
      end

      def provider_messages
        conversation.ai_messages.order(:id).filter_map { |message| to_provider(message) }
      end

      def to_provider(message)
        case message.role
        when 'user' then { role: 'user', content: message.content['text'].to_s }
        when 'assistant' then assistant_provider_message(message)
        when 'tool' then tool_provider_message(message)
        end
      end

      def assistant_provider_message(message)
        calls = Array(message.content['tool_calls'])
        return { role: 'assistant', content: message.content['text'].to_s } if calls.empty?

        blocks = []
        blocks << { type: 'text', text: message.content['text'] } if message.content['text'].present?
        calls.each do |call|
          blocks << { type: 'tool_use', id: call['id'], name: call['name'], input: call['input'] || {} }
        end
        { role: 'assistant', content: blocks }
      end

      def tool_provider_message(message)
        {
          role: 'user',
          content: [
            {
              type: 'tool_result',
              tool_use_id: message.content['tool_use_id'],
              content: message.content['result'].to_json
            }
          ]
        }
      end

      def system_prompt
        zone = Time.find_zone(organization.timezone) || Time.zone
        ERB.new(PROMPT.read, trim_mode: '-').result_with_hash(
          organization_name: organization.name.to_s,
          locale:,
          timezone: zone.tzinfo.name,
          today: Time.current.in_time_zone(zone).to_date.iso8601,
          role: user.role&.name.to_s
        )
      end

      def locale
        organization.locale.presence || I18n.default_locale.to_s
      end

      def usage_hash(result)
        return if result&.usage.nil?

        { input_tokens: result.usage.input_tokens, output_tokens: result.usage.output_tokens }
      end
    end
  end
end
