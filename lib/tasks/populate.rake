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
      WineStyle,
    ].each(&:delete_all)

    super_admin =
      User.create_with(
        password: '123123123',
        name: 'user super admin',
        confirmed_at: Time.zone.now,
        role: Role.find_by(name: 'SUPER_ADMIN'),
      ).find_or_create_by!(email: 'super@email.com')

    super_org = Organization.create_with(
      name: Faker::Company.name,
      phone: Faker::PhoneNumber.phone_number,
      user: super_admin
    ).find_or_create_by!(cnpj: Faker::Company.unique.brazilian_company_number(formatted: true))

    super_admin.update(organization: super_org)

    admin =
      User.create_with(
        password: '123123123',
        name: 'user admin',
        confirmed_at: Time.zone.now,
        role: Role.find_by(name: 'ADMIN'),
      ).find_or_create_by!(email: 'admin@email.com')

    organization = Organization.create_with(
      name: Faker::Company.name,
      phone: Faker::PhoneNumber.phone_number,
      user: admin
    ).find_or_create_by!(cnpj: Faker::Company.unique.brazilian_company_number(formatted: true))

    admin.update(organization: organization)

    User.create_with(
      password: '123123123',
      name: 'user kitchen',
      confirmed_at: Time.zone.now,
      role: Role.find_by(name: 'KITCHEN'),
      organization: organization
    ).find_or_create_by!(email: 'kitchen@email.com')

    User.create_with(
      password: '123123123',
      name: 'user waiter',
      confirmed_at: Time.zone.now,
      role: Role.find_by(name: 'WAITER'),
      organization: organization
    ).find_or_create_by!(email: 'waiter@email.com')

    User.create_with(
      password: '123123123',
      name: 'user CASH REGISTER',
      confirmed_at: Time.zone.now,
      role: Role.find_by(name: 'CASH_REGISTER'),
      organization: organization
    ).find_or_create_by!(email: 'cash_register@email.com')

    User.create_with(
      password: '123123123',
      name: 'user kitchen',
      confirmed_at: Time.zone.now,
      role: Role.find_by(name: 'CUSTOMER'),
    ).find_or_create_by!(email: 'customer@email.com')

    20.times do
      BeerStyle.find_or_create_by!(name: Faker::Beer.unique.style)
    end
    Faker::Beer.unique.clear

    20.times do
      WineStyle.find_or_create_by!(name: Faker::Beer.unique.style)
    end
    Faker::Beer.unique.clear

    100.times do
      Maker.create!(
        organization: organization,
        country: Faker::Address.country,
        name: Faker::Company.name
      )
    end
    100.times do |n|
      Table.create!(
        organization: organization,
        chairs: Faker::Number.between(from: 1, to: 12),
        name: "mesa #{n}"
      )
    end
    100.times do
      Beer.create!(
        maker: organization.makers.sample,
        beer_style: BeerStyle.all.sample,
        organization: organization,
        ibu: Faker::Number.between(from: 1, to: 99),
        abv: Faker::Number.between(from: 1, to: 99),
        name: Faker::Beer.name,
        price: Faker::Number.between(from: 1, to: 99),
        quantity_stock: Faker::Number.between(from: 1, to: 99)
      )
    end

    100.times do
      Wine.create!(
        organization: organization,
        maker: organization.makers.sample,
        wine_style: WineStyle.all.sample,
        abv: Faker::Number.between(from: 1, to: 99),
        name: Faker::Beer.name,
        price: Faker::Number.between(from: 1, to: 99),
        quantity_stock: Faker::Number.between(from: 1, to: 99),
        description: "description",
        grapes: "cabernet",
        ripening: "ripening",
        visual: "visual",
        vintage_wine: "vintage_wine"
      )
    end

    100.times do
      Drink.create!(
        organization: organization,
        maker: organization.makers.sample,
        abv: Faker::Number.between(from: 1, to: 99),
        name: Faker::Beer.name,
        price: Faker::Number.between(from: 1, to: 99),
        quantity_stock: Faker::Number.between(from: 1, to: 99)
      )
    end
    100.times do
      Food.create!(
        organization: organization,
        name: Faker::Food.ingredient,
        price: Faker::Number.between(from: 1, to: 99),
        quantity_stock: Faker::Number.between(from: 1, to: 99),
        valid_until: Faker::Date.forward(days: 30)
      )
    end
    100.times do
      Dish.create!(
        organization: organization,
        name: Faker::Food.dish,
        price: Faker::Number.between(from: 1, to: 99)
      )
    end
    100.times do
      DishIngredient.create!(
        dish: organization.dishes.sample,
        food: organization.foods.sample,
        quantity: Faker::Number.between(from: 1, to: 2)
      )
    end
  end
end
