# frozen_string_literal: true

namespace :db do
  desc 'Create closed/paid demo orders for dashboard analytics (does not wipe catalog)'
  task demo_orders: :environment do
    count = ENV.fetch('COUNT', '35').to_i
    days = ENV.fetch('DAYS', '30').to_i
    org_email = ENV.fetch('ORG_EMAIL', 'admin@email.com')

    Searchkick.callbacks(false) do
      DemoOrders.seed!(count:, days:, org_email:)
    end

    puts "Done. Created #{count} completed orders over the last #{days} days."
  end
end

module DemoOrders
  module_function

  def seed!(count:, days:, org_email:)
    org = User.find_by(email: org_email)&.organization
    org ||= Organization.first
    raise "No organization found (tried user #{org_email.inspect})" unless org

    catalog = build_catalog(org)
    if catalog[:dishes].empty? && catalog[:stock].empty?
      raise "Organization #{org.name} has no catalog items — run db:populate first"
    end

    refresh_stock!(org)

    waiter = org.users.joins(:role).find_by(roles: { name: 'WAITER' })
    tables = org.tables.to_a
    zone = org.timezone.present? ? ActiveSupport::TimeZone[org.timezone] : Time.zone
    now = zone.now

    count.times do |i|
      day_offset = (i * days / count.to_f).floor + rand(0..1)
      day_offset = [day_offset, days - 1].min
      order_time = (now - day_offset.days).change(
        hour: rand(11..22),
        min: rand(0..59),
        sec: 0
      )

      order = org.orders.create!(
        status: :open,
        table: tables.sample,
        user: waiter,
        discount_cents: 0
      )

      items_count = rand(2..5)
      items_count.times do
        item, quantity = pick_item_and_quantity(org)
        order_item = Orders::AddItem.call(
          order:,
          params: { item:, quantity: }
        )
        raise "Failed to add item: #{order_item.errors.full_messages.join(', ')}" unless order_item.persisted?

        finalize_item!(order_item, order_time)
      end

      order.recalculate_total
      finalize_order!(order, order_time, pay: rand < 0.75)
    end

    puts "Organization: #{org.name} (id=#{org.id})"
    puts "Completed orders: #{org.orders.where(status: %i[closed payed]).count}"
  end

  def refresh_stock!(org)
    [Drink, Beer, Wine, Food].each do |model|
      model.where(organization: org).update_all(quantity_stock: 500)
    end
  end

  def build_catalog(org)
    {
      dishes: Dish.where(organization: org).to_a,
      stock: [
        *Drink.where(organization: org).where('quantity_stock > 0'),
        *Beer.where(organization: org).where('quantity_stock > 0'),
        *Wine.where(organization: org).where('quantity_stock > 0')
      ]
    }
  end

  def pick_item_and_quantity(org)
    catalog = build_catalog(org)
    use_dish = catalog[:dishes].any? && (catalog[:stock].empty? || rand < 0.4)

    if use_dish
      [catalog[:dishes].sample, rand(1..2)]
    else
      item = catalog[:stock].max_by(&:quantity_stock)
      raise 'No stock-backed items available' unless item

      quantity = [rand(1..2), item.quantity_stock].min
      [item, quantity]
    end
  end

  def finalize_item!(order_item, order_time)
    if order_item.dish?
      order_item.start_cooking!
      order_item.mark_ready!
      order_item.serve!
      prep_seconds = rand(600..3600)
      order_item.update_columns(
        created_at: order_time,
        updated_at: order_time + prep_seconds
      )
    else
      order_item.update!(status: :with_the_client)
      order_item.update_columns(created_at: order_time, updated_at: order_time + rand(60..600))
    end
  end

  def finalize_order!(order, order_time, pay:)
    if pay 
      order.mark_paid!
    else
      order.close!
    end

    closed_at = order_time + rand(1800..7200)
    order.update_columns(created_at: order_time, updated_at: closed_at)
  end
end
