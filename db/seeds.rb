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

