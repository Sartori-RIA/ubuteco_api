# frozen_string_literal: true

class Dish < Product
  include PgSearch::Model

  pg_search_scope :search,
                  against: %w[name]

  belongs_to :organization

  has_many :foods, through: :dish_ingredients
  has_many :dish_ingredients, dependent: :restrict_with_error

  accepts_nested_attributes_for :dish_ingredients, allow_destroy: true
end
