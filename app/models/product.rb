# frozen_string_literal: true

class Product < ApplicationRecord
  include AttachmentUrlHelper

  self.abstract_class = true

  acts_as_paranoid

  has_many :order_items, as: :item, dependent: :restrict_with_error

  validates :name, :price, presence: true

  has_one_attached :image

  monetize :price_cents

  def image_url
    url_for_attachment(image, resize_to_limit: AttachmentUrlHelper::DISPLAY_SIZE)
  end

  def thumbnail_url
    url_for_attachment(image, resize_to_limit: AttachmentUrlHelper::THUMBNAIL_SIZE)
  end
end
