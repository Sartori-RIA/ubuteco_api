# frozen_string_literal: true

module Ai
  class AnthropicClient
    def self.complete(tier:, system:, messages:, tools:)
      new(tier:).complete(system:, messages:, tools:)
    end

    def initialize(tier:, sdk: nil)
      @tier = tier
      @sdk = sdk
    end

    def complete(system:, messages:, tools:)
      settings = Config.tier(@tier)
      response = sdk_client(settings).messages.create(**request_params(settings, system, messages, tools))
      parse(response)
    rescue ProviderError
      raise
    rescue StandardError => e
      raise ProviderError, e.message
    end

    private

    def request_params(settings, system, messages, tools)
      params = {
        model: settings.model,
        max_tokens: settings.max_tokens,
        system:,
        messages:
      }
      params[:tools] = tools if tools.present?
      params
    end

    def sdk_client(settings)
      @sdk_client ||= @sdk || Anthropic::Client.new(
        api_key: ENV.fetch('ANTHROPIC_API_KEY', nil),
        timeout: settings.timeout_seconds
      )
    end

    def parse(response)
      blocks = Array(response.content)
      Ai.result(
        text: text_from(blocks),
        tool_calls: tool_calls_from(blocks),
        input_tokens: response.usage&.input_tokens.to_i,
        output_tokens: response.usage&.output_tokens.to_i,
        stop_reason: response.stop_reason.to_s
      )
    end

    def text_from(blocks)
      blocks.filter_map { |block| block.text if block.type.to_s == 'text' }.join
    end

    def tool_calls_from(blocks)
      blocks.filter_map do |block|
        next unless block.type.to_s == 'tool_use'

        Ai::ToolCall.new(id: block.id, name: block.name, input: block.input)
      end
    end
  end
end
