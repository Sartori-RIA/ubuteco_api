# frozen_string_literal: true

class Order < ApplicationRecord
  acts_as_paranoid
  enum status: {open: 0, closed: 1, payed: 2}

  belongs_to :table, optional: true
  belongs_to :user
  has_many :order_items, dependent: :destroy

  monetize :total_cents, :total_with_discount_cents, :discount_cents

  include PgSearch::Model

  pg_search_scope :search,
                  against: %w[created_at total_cents total_with_discount_cents],
                  associated_against: {
                      table: %w[name],
                      user: %w[name]
                  }

  after_update :update_storage

  protected

  def update_storage
    return unless closed?

    order_items.map do |item|
      case item.item_type
      when 'Drink'
        drink = Drink.find_by(id: item.item_id)
        Drink.update(drink.id, quantity_stock: drink.quantity_stock - item.quantity)
      when 'Beer'
        beer = Beer.find_by(id: item.item_id)
        Beer.update(beer.id, quantity_stock: beer.quantity_stock - item.quantity)
      when 'Wine'
        wine = Wine.find_by(id: item.item_id)
        Wine.update(wine.id, quantity_stock: wine.quantity_stock - item.quantity)
      end
    end
  end
end
