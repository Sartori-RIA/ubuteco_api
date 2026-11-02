# frozen_string_literal: true

module Ai
  module Intake
    class Eval
      def self.call
        cases = Rails.root.glob('spec/ai_evals/intake/*.yml').map { |path| YAML.safe_load_file(path) }
        pending = cases.empty? || cases.any? { |item| item['image'].blank? }
        { total: cases.size, passed: 0, pending: }
      end
    end
  end
end
