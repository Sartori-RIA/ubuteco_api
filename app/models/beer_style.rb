# frozen_string_literal: true

class BeerStyle < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :beers, dependent: :restrict_with_error
end
