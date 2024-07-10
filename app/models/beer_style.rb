# frozen_string_literal: true

class BeerStyle < ApplicationRecord
  acts_as_paranoid

  searchkick callbacks: :async

  after_commit :enqueue_reindex_job

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  has_many :beers, dependent: :restrict_with_error

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
