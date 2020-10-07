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

    # User.create_with(password: '12345678',
    #                  name: 'Lucas A. R. Sartori',
    #                  company_name: 'CookieCode',
    #                  cnpj: '31.515.296/0001-07')
    #     .find_or_create_by!(email: 'admin@cookiecode.com.br')

    # Theme.create(color_footer: 'slate',
    #                   color_header: 'white',
    #                   color_sidebar: 'slate',
    #                   name: 'default',
    #                   user: User.find_by(email: 'admin@cookiecode.com.br'),
    #                   rtl: false)

    100.times do |n|
      BeerStyle.create!(
          user: User.all.sample,
          name: Faker::Beer.style
      )

      Maker.create!(
          user: User.all.sample,
          country: Faker::Address.country,
          name: Faker::Company.name
      )

      Table.create!(
          user: User.all.sample,
          chairs: Faker::Number.between(from: 1, to: 12),
          name: "mesa #{n}"
      )

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

      Drink.create!(
          user: User.all.sample,
          maker: Maker.all.sample,
          abv: Faker::Number.between(from: 1, to: 99),
          name: Faker::Beer.name,
          price: Faker::Number.between(from: 1, to: 99),
          quantity_stock: Faker::Number.between(from: 1, to: 99)
      )

      Food.create!(
          user: User.all.sample,
          name: Faker::Food.ingredient,
          price: Faker::Number.between(from: 1, to: 99),
          quantity_stock: Faker::Number.between(from: 1, to: 99),
          valid_until: Faker::Date.forward(days: 30)
      )

      Dish.create!(
          user: User.all.sample,
          name: Faker::Food.dish,
          price: Faker::Number.between(from: 1, to: 99),
      )

      DishIngredient.create!(
          dish: Dish.all.sample,
          food: Food.all.sample,
          quantity: Faker::Number.between(from: 1, to: 2),
      )

      Order.create!(
          table: Table.all.sample,
          user: User.all.sample
      )

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
