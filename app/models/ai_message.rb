# frozen_string_literal: true

class AiMessage < ApplicationRecord
  ROLES = %w[user assistant tool].freeze

  belongs_to :ai_conversation, touch: true

  validates :role, inclusion: { in: ROLES }
end
