# frozen_string_literal: true

class Dish < Product
  has_many :dish_ingredients, dependent: :restrict_with_error
  has_many :foods, through: :dish_ingredients

  belongs_to :organization

  accepts_nested_attributes_for :dish_ingredients, allow_destroy: true

  include PgSearch::Model

  pg_search_scope :search,
                  against: %w[name]

  def to_json(*_args)
    super(include: [dish_ingredients: { include: :food }])
  end
end
