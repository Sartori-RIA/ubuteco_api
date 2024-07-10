# frozen_string_literal: true

class Drink < Product
  searchkick callbacks: :async

  validates :quantity_stock, presence: true

  belongs_to :maker, optional: true
  belongs_to :organization
end
