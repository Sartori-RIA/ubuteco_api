# frozen_string_literal: true

class Beer < Product
  extend Pagy::Search

  searchkick callbacks: :async

  validates :ibu, :quantity_stock, :abv, presence: true

  belongs_to :maker
  belongs_to :beer_style
  belongs_to :organization

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }

  def search_data
    {
      name: name,
      maker: maker.name,
      style: beer_style.name
    }
  end

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
