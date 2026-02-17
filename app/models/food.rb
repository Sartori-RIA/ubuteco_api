# frozen_string_literal: true

class Food < Product
  extend Pagy::Search

  searchkick callbacks: :async

  has_many :dish_ingredients, dependent: :restrict_with_error
  has_many :dishes, through: :dish_ingredients

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
