class OrderItem < ApplicationRecord
  include KitchensHelper
  belongs_to :order
  belongs_to :item, polymorphic: true

  after_update {|order_item| order_item.message 'update'}
  after_create {|order_item| order_item.message 'create'}

  validates :quantity, presence: true, numericality: {greater_than: 0}

  enum status: [
      :awaiting,
      :cooking,
      :ready,
      :with_the_client,
      :canceled,
      :empty_stock
  ]

  def message(action)
    msg = {
        obj: format_dish_to_make(self),
        action: action,
        room: self.order.user.email
    }
    $redis.publish 'kitchen', msg.to_json
  end

end
