# frozen_string_literal: true

class Table < ApplicationRecord
  acts_as_paranoid
  validates :name, :chairs, presence: true

  belongs_to :organization

  include PgSearch::Model

  pg_search_scope :search, against: %w[name]
end
