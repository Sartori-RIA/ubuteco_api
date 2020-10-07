# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_10_234018) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beer_styles", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_beer_styles_on_deleted_at"
    t.index ["user_id"], name: "index_beer_styles_on_user_id"
  end

  create_table "beers", force: :cascade do |t|
    t.string "name"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "BRL", null: false
    t.string "image"
    t.integer "quantity_stock"
    t.text "description"
    t.decimal "abv"
    t.decimal "ibu"
    t.datetime "valid_until"
    t.bigint "maker_id"
    t.bigint "beer_style_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["beer_style_id"], name: "index_beers_on_beer_style_id"
    t.index ["deleted_at"], name: "index_beers_on_deleted_at"
    t.index ["maker_id"], name: "index_beers_on_maker_id"
    t.index ["user_id"], name: "index_beers_on_user_id"
  end

  create_table "dish_ingredients", force: :cascade do |t|
    t.bigint "food_id"
    t.bigint "dish_id"
    t.decimal "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id"], name: "index_dish_ingredients_on_dish_id"
    t.index ["food_id"], name: "index_dish_ingredients_on_food_id"
  end

  create_table "dishes", force: :cascade do |t|
    t.string "name"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "BRL", null: false
    t.string "image"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_dishes_on_deleted_at"
    t.index ["user_id"], name: "index_dishes_on_user_id"
  end

  create_table "drinks", force: :cascade do |t|
    t.string "name"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "BRL", null: false
    t.string "image"
    t.integer "quantity_stock"
    t.text "description"
    t.string "flavor"
    t.decimal "abv"
    t.bigint "maker_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_drinks_on_deleted_at"
    t.index ["maker_id"], name: "index_drinks_on_maker_id"
    t.index ["user_id"], name: "index_drinks_on_user_id"
  end

  create_table "foods", force: :cascade do |t|
    t.string "name"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "BRL", null: false
    t.string "image"
    t.integer "quantity_stock"
    t.datetime "valid_until"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_foods_on_deleted_at"
    t.index ["user_id"], name: "index_foods_on_user_id"
  end

  create_table "makers", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_makers_on_deleted_at"
    t.index ["user_id"], name: "index_makers_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id"
    t.integer "quantity"
    t.string "item_type"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["item_type", "item_id"], name: "index_order_items_on_item_type_and_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "total_cents", default: 0, null: false
    t.string "total_currency", default: "BRL", null: false
    t.integer "total_with_discount_cents", default: 0, null: false
    t.string "total_with_discount_currency", default: "BRL", null: false
    t.integer "discount_cents", default: 0, null: false
    t.string "discount_currency", default: "BRL", null: false
    t.bigint "table_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["table_id"], name: "index_orders_on_table_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "tables", force: :cascade do |t|
    t.string "name"
    t.integer "chairs"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_tables_on_deleted_at"
    t.index ["user_id"], name: "index_tables_on_user_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.string "color_header"
    t.string "color_sidebar"
    t.string "color_footer"
    t.boolean "rtl"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_themes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "company_name"
    t.string "cnpj"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "whitelisted_jwts", force: :cascade do |t|
    t.string "jti", null: false
    t.string "aud"
    t.datetime "exp", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_whitelisted_jwts_on_jti", unique: true
    t.index ["user_id"], name: "index_whitelisted_jwts_on_user_id"
  end

  create_table "wine_styles", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_wine_styles_on_deleted_at"
    t.index ["user_id"], name: "index_wine_styles_on_user_id"
  end

  create_table "wines", force: :cascade do |t|
    t.string "name"
    t.integer "quantity_stock"
    t.string "image"
    t.decimal "abv"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "BRL", null: false
    t.text "description"
    t.bigint "maker_id"
    t.integer "vintage_wine"
    t.string "visual"
    t.string "ripening"
    t.string "grapes"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "wine_style_id"
    t.index ["deleted_at"], name: "index_wines_on_deleted_at"
    t.index ["maker_id"], name: "index_wines_on_maker_id"
    t.index ["user_id"], name: "index_wines_on_user_id"
    t.index ["wine_style_id"], name: "index_wines_on_wine_style_id"
  end

  add_foreign_key "beer_styles", "users"
  add_foreign_key "beers", "beer_styles"
  add_foreign_key "beers", "makers"
  add_foreign_key "beers", "users"
  add_foreign_key "dish_ingredients", "dishes"
  add_foreign_key "dish_ingredients", "foods"
  add_foreign_key "dishes", "users"
  add_foreign_key "drinks", "makers"
  add_foreign_key "drinks", "users"
  add_foreign_key "foods", "users"
  add_foreign_key "makers", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "tables"
  add_foreign_key "orders", "users"
  add_foreign_key "tables", "users"
  add_foreign_key "themes", "users"
  add_foreign_key "whitelisted_jwts", "users", on_delete: :cascade
  add_foreign_key "wine_styles", "users"
  add_foreign_key "wines", "makers"
  add_foreign_key "wines", "users"
  add_foreign_key "wines", "wine_styles"
end
