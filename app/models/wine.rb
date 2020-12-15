# frozen_string_literal: true

class Wine < Product
  validates :abv,
            :quantity_stock,
            :description,
            :vintage_wine,
            :maker,
            :visual,
            :ripening,
            :grapes,
            :wine_style,
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

  def to_json(*_args)
    super(include: %i[wine_style maker])
  end
end
