# frozen_string_literal: true

class Dish < Product
  include CatalogEmbeddable
  extend Pagy::Search

  searchkick callbacks: :async, knn: CatalogEmbeddable::KNN

  belongs_to :organization

  has_many :dish_ingredients, dependent: :delete_all
  has_many :foods, through: :dish_ingredients

  accepts_nested_attributes_for :dish_ingredients, allow_destroy: true

  def search_data
    {
      name: name,
      organization_id: organization_id
    }.merge(embedding_for_index)
  end
end
