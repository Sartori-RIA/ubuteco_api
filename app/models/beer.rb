# frozen_string_literal: true

class Beer < Product
  include CatalogEmbeddable
  extend Pagy::Search

  searchkick callbacks: :async, knn: CatalogEmbeddable::KNN

  validates :ibu, :quantity_stock, :abv, presence: true

  belongs_to :maker
  belongs_to :beer_style
  belongs_to :organization

  def search_data
    {
      name: name,
      maker: maker.name,
      style: beer_style.name,
      organization_id: organization_id
    }.merge(embedding_for_index)
  end
end
