# frozen_string_literal: true

namespace :db do
  desc 'Erase and Fill database'
  task populate: :environment do
    [
      OrderItem,
      Order,
      DishIngredient,
      Dish,
      Food,
      Beer,
      Drink,
      Wine,
      Maker,
      BeerStyle,
      WineStyle
    ].each(&:delete_all)

    100.times do
      BeerStyle.create!(
        name: Faker::Beer.style
      )
    end
    100.times do
      Maker.create!(
        user: User.all.sample,
        country: Faker::Address.country,
        name: Faker::Company.name
      )
    end
    100.times do |n|
      Table.create!(
        user: User.all.sample,
        chairs: Faker::Number.between(from: 1, to: 12),
        name: "mesa #{n}"
      )
    end
    100.times do
      Beer.create!(
        maker: Maker.all.sample,
        beer_style: BeerStyle.all.sample,
        user: User.all.sample,
        ibu: Faker::Number.between(from: 1, to: 99),
        abv: Faker::Number.between(from: 1, to: 99),
        name: Faker::Beer.name,
        price: Faker::Number.between(from: 1, to: 99),
        quantity_stock: Faker::Number.between(from: 1, to: 99)
      )
    end
    100.times do
      Drink.create!(
        user: User.all.sample,
        maker: Maker.all.sample,
        abv: Faker::Number.between(from: 1, to: 99),
        name: Faker::Beer.name,
        price: Faker::Number.between(from: 1, to: 99),
        quantity_stock: Faker::Number.between(from: 1, to: 99)
      )
    end
    100.times do
      Food.create!(
        user: User.all.sample,
        name: Faker::Food.ingredient,
        price: Faker::Number.between(from: 1, to: 99),
        quantity_stock: Faker::Number.between(from: 1, to: 99),
        valid_until: Faker::Date.forward(days: 30)
      )
    end
    100.times do
      Dish.create!(
        user: User.all.sample,
        name: Faker::Food.dish,
        price: Faker::Number.between(from: 1, to: 99)
      )
    end
    100.times do
      DishIngredient.create!(
        dish: Dish.all.sample,
        food: Food.all.sample,
        quantity: Faker::Number.between(from: 1, to: 2)
      )
    end
    100.times do
      Order.create!(
        table: Table.all.sample,
        user: User.all.sample
      )
    end

    100.times do
      clazz = [Drink, Beer, Dish].sample
      OrderItem.create!(
        order: Order.all.sample,
        quantity: Faker::Number.between(from: 1, to: 2),
        item: clazz.all.sample,
        status: OrderItem.statuses.values.sample
      )
    end
  end
end
