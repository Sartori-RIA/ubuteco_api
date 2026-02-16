# frozen_string_literal: true

class Maker < ApplicationRecord
  extend Pagy::Search

  acts_as_paranoid

  searchkick callbacks: :async

  has_one_attached :image

  validates :name, :country, presence: true

  has_many :drinks, dependent: :destroy
  has_many :beers, dependent: :destroy

  belongs_to :organization
end
