# frozen_string_literal: true

class Dish < Product
  extend Pagy::Search

  searchkick callbacks: :async

  belongs_to :organization

  has_many :dish_ingredients, dependent: :delete_all
  has_many :foods, through: :dish_ingredients

  accepts_nested_attributes_for :dish_ingredients, allow_destroy: true

  after_commit :enqueue_reindex_job, unless: -> { Rails.env.test? }

  def search_data
    {
      name: name,
      organization_id: organization_id
    }
  end

  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
