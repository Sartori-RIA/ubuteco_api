# frozen_string_literal: true

class Food < Product
  include OrganizationScoped
  include OrganizationReindexable

  extend Pagy::Search

  searchkick callbacks: :async

  has_many :dish_ingredients, dependent: :restrict_with_error
  has_many :dishes, through: :dish_ingredients

  belongs_to :organization

  def search_data
    {
      name: name,
      organization_id: organization_id
    }
  end
end
