# frozen_string_literal: true

module Organizations
  module DailyBrief
    class Compose
      PROMPT = Rails.root.join('app/prompts/daily_brief/system.md.erb')

      def self.call(organization:, user: nil)
        new(organization:, user:).call
      end

      def initialize(organization:, user:)
        @organization = organization
        @user = user
        @facts = Facts.call(organization:)
      end

      def call
        text = narrative
        {
          text:,
          source: @source,
          facts: @facts,
          generated_at: Time.current.iso8601
        }
      end

      private

      def narrative
        return fallback unless Ai.enabled_for?(@organization)

        text = Ai::Client.complete(
          feature: Ai::Feature::DAILY_BRIEF,
          tier: :fast,
          organization: @organization,
          user: @user,
          system: system_prompt,
          messages: [{ role: 'user', content: @facts.to_json }]
        ).text
        return fallback unless Ai::NumberGuard.covers?(text, @facts)

        @source = 'ai'
        text
      rescue Ai::Error
        fallback
      end

      def fallback
        @source = 'template'
        Template.call(@facts)
      end

      def system_prompt
        ERB.new(PROMPT.read).result_with_hash(locale: @facts[:locale])
      end
    end
  end
end
