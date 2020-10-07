FactoryBot.define do
  factory :wine do
    name { "MyString" }
    quantity_stock { 20 }
    image { "MyString" }
    abv { 30 }
    price { 10 }
    description { "MyText" }
    vintage_wine { 2010 }
    visual { "MyString" }
    ripening { "Ripening" }
    grapes { "MyString" }
    user
    maker
    wine_style
  end
end
