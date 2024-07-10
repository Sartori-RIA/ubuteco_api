# frozen_string_literal: true

class Beer < Product
  searchkick callbacks: :async

  validates :ibu, :quantity_stock, :abv, presence: true

  belongs_to :maker
  belongs_to :beer_style
  belongs_to :organization
end
