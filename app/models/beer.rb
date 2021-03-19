# frozen_string_literal: true

class Beer < Product
  validates :ibu, :quantity_stock, :abv, presence: true

  belongs_to :maker
  belongs_to :beer_style
  belongs_to :organization

  include PgSearch::Model

  pg_search_scope :search,
                  against: %w[name],
                  associated_against: {
                    maker: %w[name],
                    beer_style: %w[name]
                  }
end
