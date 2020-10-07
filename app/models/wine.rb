# frozen_string_literal: true

class Wine < Product
  validates :abv, presence: true
  validates :quantity_stock, presence: true
  validates :description, presence: true
  validates :vintage_wine, presence: true
  validates :visual, presence: true
  validates :ripening, presence: true
  validates :grapes, presence: true
  validates :wine_style, presence: true
  validates :maker, presence: true

  belongs_to :maker
  belongs_to :wine_style
  belongs_to :user

  def to_json(*_args)
    super(include: %i[wine_style maker])
  end
end
