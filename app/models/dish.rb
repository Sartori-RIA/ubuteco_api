# frozen_string_literal: true

class Dish < Product
  searchkick callbacks: :async

  belongs_to :organization

  has_many :dish_ingredients, dependent: :delete_all
  has_many :foods, through: :dish_ingredients

  accepts_nested_attributes_for :dish_ingredients, allow_destroy: true
end
