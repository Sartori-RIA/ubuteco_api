# frozen_string_literal: true

class Maker < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true
  validates :country, presence: true

  has_many :drinks, dependent: :destroy
  has_many :beers, dependent: :destroy

  belongs_to :user
end
