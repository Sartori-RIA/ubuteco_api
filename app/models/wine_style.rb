# frozen_string_literal: true

class WineStyle < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false

  has_many :wines, dependent: :restrict_with_error

  pg_search_scope :search, against: %w[name]
end
