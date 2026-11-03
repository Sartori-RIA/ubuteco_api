# frozen_string_literal: true

module Ai
  class FakeClient
    class << self
      def reset!
        @queue = []
        @calls = []
      end

      def enqueue(item)
        queue << item
      end

      def calls
        @calls ||= []
      end

      def complete(tier:, system:, messages:, tools:)
        calls << { tier:, system:, messages:, tools: }
        item = queue.shift
        return Ai.result(text: 'ok') if item.nil?

        raise item if item.is_a?(Exception)

        item
      end

      private

      def queue
        @queue ||= []
      end
    end
  end
end
