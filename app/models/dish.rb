# frozen_string_literal: true

class Dish < Product
  has_many :dish_ingredients
  has_many :foods, through: :dish_ingredients

  belongs_to :user

  accepts_nested_attributes_for :dish_ingredients, allow_destroy: true

  def to_json(*_args)
    super(include: [dish_ingredients: { include: :food }])
  end
end
