# frozen_string_literal: true

class Maker < ApplicationRecord
  acts_as_paranoid

  validates :name, :country, presence: true

  has_many :drinks, dependent: :destroy
  has_many :beers, dependent: :destroy

  belongs_to :organization

  include PgSearch::Model

  pg_search_scope :search, against: %w[name country]
end
