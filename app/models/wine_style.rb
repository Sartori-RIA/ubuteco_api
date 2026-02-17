# frozen_string_literal: true

class WineStyle < ApplicationRecord
  extend Pagy::Search

  searchkick callbacks: :async

  acts_as_paranoid

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  has_many :wines, dependent: :restrict_with_error

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }

  def search_data
    { name: name }
  end

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
