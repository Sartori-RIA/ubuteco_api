# frozen_string_literal: true

class DishIngredient < ApplicationRecord
  belongs_to :dish
  belongs_to :food

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :food_id, uniqueness: { scope: :dish_id }

  accepts_nested_attributes_for :food, allow_destroy: true
  accepts_nested_attributes_for :dish, allow_destroy: true
end
