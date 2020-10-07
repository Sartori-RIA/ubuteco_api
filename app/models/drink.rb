# frozen_string_literal: true

class Drink < Product
  validates :quantity_stock, presence: true

  belongs_to :maker, optional: true
  belongs_to :user
end
