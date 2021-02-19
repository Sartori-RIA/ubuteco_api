# frozen_string_literal: true

%w[SUPER_ADMIN ADMIN KITCHEN WAITER CASH_REGISTER CUSTOMER].each { |role| Role.find_or_create_by!(name: role) }

[
  'Pilsner',
  'American larger',
  'Premium Lager',
  'Helles',
  'Dortmunder Export',
  'Japanese Rice Lager',
  'Munich Dunkel',
  'American Dark Lager',
  'Malzbier',
  'Schwarzbier',
  'Tradicional Bock',
  'Doppelbock',
  'Helles Bock',
  'Vienna',
  'Marzen Lager',
  'American Pale Ale',
  'English IPA',
  'American Amber Ale',
  'American Strong Ale',
  'Weissbier',
  'Hefeweizen',
  'Dunkelweizen',
  'Weizenbock',
  'Witbier',
  'Berliner Weisse',
  'Stout',
  'Dry Stout',
  'American Stout',
  'Sweet Stout',
  'Oatmeal Stout',
  'Russian Imperial Stout',
  'Gueuze',
  'Faro',
  'Fruit Lambic',
  'Straight Lambics'
].each { |beer_style| BeerStyle.find_or_create_by!(name: beer_style) }

[
  'Cabernet Sauvignon',
  'Malbec',
  'Merlot',
  'Tannat',
  'Pinot Noir',
  'Chardonnay'
].each { |wine_style| WineStyle.find_or_create_by!(name: wine_style) }

# User.create_with(password: '123123123',
#                 name: 'Lucas A. R. Sartori',
#                 company_name: 'CookieCode',
#                 confirmed_at: Time.zone.now,
#                 role_id: Role.find_by(name: 'ADMIN').id,
#                 cnpj: '31.515.296/0001-07')
#    .find_or_create_by!(email: 'admin@cookiecode.com.br')
#
# User.create_with(password: '123123123',
#                 name: 'restaurante',
#                 company_name: 'Armazem do malte',
#                 confirmed_at: Time.zone.now,
#                 cnpj: '44.977.683/0001-07')
#    .find_or_create_by!(email: 'teste@email.com')
