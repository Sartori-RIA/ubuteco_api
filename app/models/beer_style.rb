# frozen_string_literal: true

class BeerStyle < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  has_many :beers, dependent: :restrict_with_error
end
