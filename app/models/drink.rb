# frozen_string_literal: true

class Drink < Product
  include CatalogEmbeddable
  extend Pagy::Search

  searchkick callbacks: :async, knn: CatalogEmbeddable::KNN

  validates :quantity_stock, presence: true

  belongs_to :organization

  def search_data
    {
      name: name,
      organization_id: organization_id
    }.merge(embedding_for_index)
  end
end
