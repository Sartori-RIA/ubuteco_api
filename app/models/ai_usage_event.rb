# frozen_string_literal: true

class AiUsageEvent < ApplicationRecord
  STATUSES = %w[ok error rate_limited disabled].freeze

  belongs_to :organization
  belongs_to :user, optional: true

  validates :feature, inclusion: { in: Ai::Feature::ALL }
  validates :status, inclusion: { in: STATUSES }
end
