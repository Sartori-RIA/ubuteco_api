# frozen_string_literal: true

module KitchensHelper
  def format_dish_to_make(dish)
    {
      id: dish.id,
      status: dish.status,
      created_at: dish.created_at,
      updated_at: dish.updated_at,
      table: Table.find_by(id: dish.order.table_id),
      order_item: dish,
      dish: dish.item
    }
  end
end
