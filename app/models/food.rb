# frozen_string_literal: true

class Food < Product
  has_many :dish_ingredients, dependent: :restrict_with_error
  has_many :foods, through: :dish_ingredients

  belongs_to :user

  include PgSearch::Model

  pg_search_scope :search,
                  against: %w[name]
end
