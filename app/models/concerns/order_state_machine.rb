# frozen_string_literal: true

module OrderStateMachine
  extend ActiveSupport::Concern

  PERMITTED_TRANSITIONS = {
    "open" => %w[closed payed],
    "closed" => %w[payed],
    "payed" => []
  }.freeze

  included do
    include AASM

    aasm column: :status, enum: true do
      state :open, initial: true
      state :closed, :payed

      event :close do
        transitions from: :open, to: :closed
      end

      event :mark_paid do
        transitions from: %i[open closed], to: :payed
      end
    end

    validate :status_transition_must_be_allowed, if: :validate_status_transition?
  end

  private

  def validate_status_transition?
    will_save_change_to_status? && !new_record?
  end

  def status_transition_must_be_allowed
    from = status_was.to_s
    to = status.to_s
    return if from == to

    allowed = PERMITTED_TRANSITIONS.fetch(from, [])
    return if allowed.include?(to)

    errors.add(:status, :invalid_transition, from:, to:)
  end
end
