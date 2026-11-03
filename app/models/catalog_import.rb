# frozen_string_literal: true

class CatalogImport < ApplicationRecord
  STATUSES = %w[queued running completed failed].freeze
  PRODUCT_TYPES = %w[beer drink wine food dish].freeze
  ACTIVE_STATUSES = %w[queued running].freeze
  RUNTIME_SAMPLE = 20

  belongs_to :organization
  belongs_to :user

  has_one_attached :file

  validates :product_type, inclusion: { in: PRODUCT_TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: ACTIVE_STATUSES) }
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def queued?
    status == 'queued'
  end

  def estimated_start_at
    return unless queued?

    median = self.class.median_runtime
    return if median.nil?

    Time.current + (jobs_ahead * median)
  end

  def jobs_ahead
    running = self.class.where(status: 'running').count
    running + queued_before.count
  end

  def as_status_json(include_log: false)
    payload = {
      id:,
      product_type:,
      status:,
      total_rows:,
      created_rows:,
      failed_rows:,
      processed_rows:,
      error_message:,
      enqueued_at:,
      started_at:,
      finished_at:,
      estimated_start_at:
    }
    payload[:row_log] = row_log if include_log
    payload
  end

  def self.median_runtime
    durations = finished_durations
    return if durations.empty?

    sorted = durations.sort
    mid = sorted.length / 2
    return sorted[mid] if sorted.length.odd?

    (sorted[mid - 1] + sorted[mid]) / 2.0
  end

  def self.finished_durations
    where(status: %w[completed failed])
      .where('started_at IS NOT NULL AND finished_at IS NOT NULL')
      .order(finished_at: :desc)
      .limit(RUNTIME_SAMPLE)
      .pluck(:started_at, :finished_at)
      .map { |started, finished| finished - started }
  end

  private

  def queued_before
    self.class.where(status: 'queued').where(
      'enqueued_at < :at OR (enqueued_at = :at AND id < :id)',
      at: enqueued_at,
      id:
    )
  end
end
