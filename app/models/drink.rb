# frozen_string_literal: true

class Drink < Product
  validates :quantity_stock, presence: true

  belongs_to :maker, optional: true
  belongs_to :user

  include PgSearch::Model

  pg_search_scope :search,
                  against: %w[name],
                  associated_against: {
                      maker: %w[name],
                  }
end
