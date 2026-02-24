# frozen_string_literal: true

class Drink < Product
  extend Pagy::Search

  searchkick callbacks: :async

  validates :quantity_stock, presence: true

  belongs_to :organization

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }

  def search_data
    {
      name: name
    }
  end

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
