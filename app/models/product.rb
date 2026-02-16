# frozen_string_literal: true

class Product < ApplicationRecord
  self.abstract_class = true

  extend Pagy::Search

  searchkick callbacks: :async

  acts_as_paranoid

  has_many :order_items, as: :item, dependent: :restrict_with_error

  validates :name, :price, presence: true

  # has_one_attached :image

  monetize :price_cents

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
