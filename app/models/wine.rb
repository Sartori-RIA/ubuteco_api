# frozen_string_literal: true

class Wine < Product
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

  include PgSearch::Model

  pg_search_scope :search,
                  against: %w[name],
                  associated_against: {
                    wine_style: %w[name]
                  }
end
