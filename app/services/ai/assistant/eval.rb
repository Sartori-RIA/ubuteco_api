# frozen_string_literal: true

module Ai
  module Assistant
    class Eval
      def self.call
        new.call
      end

      def call
        cases = Rails.root.glob('spec/ai_evals/assistant/*.yml')
        raise ArgumentError, 'No eval cases found' if cases.empty?

        results = cases.map { |path| run_case(YAML.safe_load_file(path)) }
        { passed: results.count(true), total: results.size }
      end

      private

      def run_case(example)
        conversation = AiConversation.create!(organization:, user:, title: example['name'])
        conversation.ai_messages.create!(role: 'user', content: { 'text' => example.fetch('question') })
        text = Run.call(conversation:, user:, organization:, ability:)
        case_passed?(conversation, example, text)
      ensure
        conversation&.ai_messages&.delete_all
        conversation&.really_destroy!
      end

      def case_passed?(conversation, example, text)
        tools = conversation.ai_messages.where(role: 'tool').pluck(:tool_name)
        expected = Array(example['expected_tools'])
        facts = Array(example['must_include'])
        expected.all? { |name| tools.include?(name) } && facts.all? { |fact| text.to_s.include?(fact.to_s) }
      end

      def organization
        @organization ||= Organization.find(ENV.fetch('AI_EVAL_ORGANIZATION_ID'))
      end

      def user
        @user ||= organization.user
      end

      def ability
        @ability ||= Abilities::AdminAbility.new(
          user:,
          params: {},
          controller_name: 'Api::V1::Assistant::Conversations'
        )
      end
    end
  end
end
