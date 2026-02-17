# frozen_string_literal: true

class Maker < ApplicationRecord
  extend Pagy::Search

  acts_as_paranoid

  searchkick callbacks: :async

  has_one_attached :image

  validates :name, :country, presence: true

  has_many :drinks, dependent: :destroy
  has_many :beers, dependent: :destroy

  belongs_to :organization

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }

  def search_data
    { name: name }
  end

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
