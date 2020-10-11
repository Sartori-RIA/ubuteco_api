# frozen_string_literal: true

class Product < ApplicationRecord
  self.abstract_class = true

  acts_as_paranoid

  has_many :order_items, as: :item, dependent: :restrict_with_error

  validates :name, :price, presence: true

  mount_uploader :image, ProductPictureUploader

  monetize :price_cents
end
