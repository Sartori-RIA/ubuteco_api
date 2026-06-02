# frozen_string_literal: true

class Drink < Product
  include OrganizationScoped
  include OrganizationReindexable
  include ImmediateSearchkickIndexing

  extend Pagy::Search

  searchkick callbacks: :async

  validates :quantity_stock, presence: true

  belongs_to :organization

  def search_data
    {
      name: name,
      organization_id: organization_id
    }
  end
end
