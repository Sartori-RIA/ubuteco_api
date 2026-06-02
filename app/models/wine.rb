# frozen_string_literal: true

class Wine < Product
  extend Pagy::Search

  searchkick callbacks: :async

  validates :abv,
            :quantity_stock,
            :description,
            :vintage_wine,
            :visual,
            :ripening,
            :grapes,
            presence: true

  belongs_to :maker
  belongs_to :wine_style
  belongs_to :organization

  def search_data
    {
      name: name,
      maker: maker.name,
      style: wine_style.name,
      grapes: grapes,
      organization_id: organization_id
    }
  end
end
