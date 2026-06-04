# frozen_string_literal: true

module OrderItemStateMachine
  extend ActiveSupport::Concern

  DISH_TRANSITIONS = {
    awaiting: %i[cooking canceled],
    cooking: %i[ready canceled],
    ready: %i[with_the_client canceled],
    with_the_client: [],
    canceled: [],
    empty_stock: []
  }.freeze

  NON_DISH_TRANSITIONS = {
    awaiting: %i[with_the_client canceled empty_stock],
    with_the_client: [],
    canceled: [],
    empty_stock: [],
    cooking: [],
    ready: []
  }.freeze

  included do
    include AASM

    aasm column: :status, enum: true do
      state :awaiting, initial: true
      state :cooking, :ready, :with_the_client, :canceled, :empty_stock

      event :start_cooking do
        transitions from: :awaiting, to: :cooking
      end

      event :mark_ready do
        transitions from: :cooking, to: :ready
      end

      event :serve do
        transitions from: :ready, to: :with_the_client
      end

      event :cancel do
        transitions from: %i[awaiting cooking ready], to: :canceled
      end

      event :mark_empty_stock do
        transitions from: :awaiting, to: :empty_stock
      end
    end

    validate :status_transition_must_be_allowed, if: :validate_status_transition?
  end

  private

  def validate_status_transition?
    will_save_change_to_status? && !new_record?
  end

  def status_transition_must_be_allowed
    from = status_was&.to_sym
    to = status&.to_sym
    return if to.nil?
    return if from == to

    allowed = dish? ? DISH_TRANSITIONS[from] : NON_DISH_TRANSITIONS[from]
    return if allowed&.include?(to)

    errors.add(:status, "cannot transition from #{from} to #{to}")
  end
end
