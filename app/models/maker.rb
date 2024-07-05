# frozen_string_literal: true

class Maker < ApplicationRecord
  acts_as_paranoid

  searchkick callbacks: :async

  validates :name, :country, presence: true

  has_many :drinks, dependent: :destroy
  has_many :beers, dependent: :destroy

  belongs_to :organization
end
