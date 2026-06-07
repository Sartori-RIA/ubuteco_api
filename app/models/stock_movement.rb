# frozen_string_literal: true

class StockMovement < ApplicationRecord
  belongs_to :organization
  belongs_to :product, polymorphic: true
  belongs_to :user, optional: true
  belongs_to :order_item, optional: true

  validates :delta, presence: true, exclusion: { in: [0] }
end
