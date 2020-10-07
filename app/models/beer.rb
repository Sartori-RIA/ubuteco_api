# frozen_string_literal: true

class Beer < Product
  validates :ibu, presence: true
  validates :abv, presence: true
  validates :quantity_stock, presence: true
  validates :maker, presence: true
  validates :beer_style, presence: true
  belongs_to :maker
  belongs_to :beer_style
  belongs_to :user

  def to_json(*_args)
    super(include: %i[beer_style maker])
  end
end
