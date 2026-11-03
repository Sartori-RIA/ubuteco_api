# frozen_string_literal: true

namespace :db do
  desc 'Erase and Fill database'
  task populate: :environment do
    Searchkick.callbacks(false) do
      populate_catalog_and_users!
    end

    puts 'Reindexing OpenSearch (Searchkick)...'
    SearchkickReindex.all!
    puts 'Done.'
  end

  def populate_catalog_and_users!
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
    ].each(&:delete_all)

    default_pwd = 'ubuteco-local-dev'
    super_admin = upsert_demo_user!(
      email: 'super@email.com',
      name: 'user super admin',
      role_name: 'SUPER_ADMIN',
      password: default_pwd
    )

    super_org = Organization.create(
      name: Faker::Company.name,
      phone: Faker::PhoneNumber.phone_number,
      user: super_admin
    )

    super_admin.update(organization: super_org)

    admin = upsert_demo_user!(
      email: 'admin@email.com',
      name: 'user admin',
      role_name: 'ADMIN',
      password: default_pwd
    )

    organization = Organization.create(
      name: Faker::Company.name,
      phone: Faker::PhoneNumber.phone_number,
      user: admin
    )

    admin.update(organization_id: organization.id)

    sync_org_staff!(organization:, default_pwd:)

    upsert_demo_user!(
      email: 'customer@email.com',
      name: 'user customer',
      role_name: 'CUSTOMER',
      password: default_pwd
    )

    User.update_all(confirmed_at: Time.zone.now)

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
    seed_expiry_samples!(organization)
    100.times do
      Dish.create!(
        organization: organization,
        name: Faker::Food.dish,
        price: Faker::Number.between(from: 1, to: 99)
      )
    end
    100.times do
      DishIngredient.where(
        dish: organization.dishes.sample,
        food: organization.foods.sample,
        quantity: Faker::Number.between(from: 1, to: 2)
      ).first_or_create
    end
  end

  # Named beers and foods so /inventory expiry has a stable demo:
  # due today, due in 3 days, already expired, and 21 days out (outside the default 7-day window).
  def seed_expiry_samples!(organization)
    zone = Time.find_zone!(organization.timezone.presence || 'UTC')
    today = Time.current.in_time_zone(zone).to_date
    maker = organization.makers.sample
    beer_style = BeerStyle.all.sample

    [
      ['DEMO IPA vence hoje', 0],
      ['DEMO Lager vence em 3 dias', 3],
      ['DEMO Stout vencida', -3],
      ['DEMO Pilsen fora da janela', 21]
    ].each do |name, offset|
      on = today + offset
      Beer.create!(
        maker: maker,
        beer_style: beer_style,
        organization: organization,
        ibu: 30,
        abv: 5,
        name: name,
        price: 12,
        quantity_stock: 20,
        valid_until: zone.local(on.year, on.month, on.day, 12, 0)
      )
    end

    [
      ['DEMO pão vence amanhã', 1],
      ['DEMO queijo vencido', -1],
      ['DEMO arroz fora da janela', 21]
    ].each do |name, offset|
      on = today + offset
      Food.create!(
        organization: organization,
        name: name,
        price: 8,
        quantity_stock: 10,
        valid_until: zone.local(on.year, on.month, on.day, 12, 0)
      )
    end
  end

  def upsert_demo_user!(email:, name:, role_name:, password:, organization: nil)
    user = User.find_or_initialize_by(email: email)
    user.assign_attributes(
      password: password,
      name: name,
      role: Role.find_by!(name: role_name),
      organization: organization
    )
    user.save!
    user
  end

  def sync_org_staff!(organization:, default_pwd:)
    [
      ['kitchen@email.com', 'user kitchen', 'KITCHEN'],
      ['waiter@email.com', 'user waiter', 'WAITER'],
      ['cash_register@email.com', 'user CASH REGISTER', 'CASH_REGISTER']
    ].each do |email, name, role_name|
      upsert_demo_user!(email:, name:, role_name:, password: default_pwd, organization:)
    end
  end
end
