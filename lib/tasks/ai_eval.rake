# frozen_string_literal: true

namespace :ai do
  desc 'Run assistant evals against the real model. Usage: bin/rails ai:eval[assistant]'
  task :eval, [:suite] => :environment do |_task, args|
    abort 'Usage: bin/rails ai:eval[assistant] or ai:eval[intake]' unless %w[assistant intake].include?(args[:suite])
    abort 'Set ANTHROPIC_API_KEY' if ENV['ANTHROPIC_API_KEY'].blank?
    abort 'Set AI_EVAL_ORGANIZATION_ID' if ENV['AI_EVAL_ORGANIZATION_ID'].blank?
    abort 'Refusing to eval with AI_CLIENT=fake' if ENV['AI_CLIENT'] == 'fake'

    result = args[:suite] == 'assistant' ? Ai::Assistant::Eval.call : Ai::Intake::Eval.call
    abort 'Intake eval photos are not in the repo yet' if result[:pending]
    puts "#{result[:passed]}/#{result[:total]}"
    abort 'Eval pass rate below 90%' if result[:passed].to_f / result[:total] < 0.9
  end
end
