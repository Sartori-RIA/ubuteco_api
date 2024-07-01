# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_04_22_190557) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allowlisted_jwts", force: :cascade do |t|
    t.string "jti"
    t.string "aud"
    t.datetime "exp"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_allowlisted_jwts_on_user_id"
  end

  create_table "beer_styles", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_beer_styles_on_deleted_at"
    t.index ["name"], name: "index_beer_styles_on_name", unique: true
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
    t.bigint "organization_id"
    t.index ["beer_style_id"], name: "index_beers_on_beer_style_id"
    t.index ["deleted_at"], name: "index_beers_on_deleted_at"
    t.index ["maker_id"], name: "index_beers_on_maker_id"
    t.index ["organization_id"], name: "index_beers_on_organization_id"
  end

  create_table "dish_ingredients", force: :cascade do |t|
    t.bigint "food_id"
    t.bigint "dish_id"
    t.decimal "quantity", precision: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id"], name: "index_dish_ingredients_on_dish_id"
    t.index ["food_id", "dish_id"], name: "dish_and_food_ingredient", unique: true
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
    t.bigint "organization_id"
    t.index ["deleted_at"], name: "index_dishes_on_deleted_at"
    t.index ["organization_id"], name: "index_dishes_on_organization_id"
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
    t.bigint "organization_id"
    t.index ["deleted_at"], name: "index_drinks_on_deleted_at"
    t.index ["maker_id"], name: "index_drinks_on_maker_id"
    t.index ["organization_id"], name: "index_drinks_on_organization_id"
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
    t.bigint "organization_id"
    t.index ["deleted_at"], name: "index_foods_on_deleted_at"
    t.index ["organization_id"], name: "index_foods_on_organization_id"
  end

  create_table "makers", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.index ["deleted_at"], name: "index_makers_on_deleted_at"
    t.index ["organization_id"], name: "index_makers_on_organization_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id"
    t.integer "quantity"
    t.string "item_type"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["item_type", "item_id"], name: "index_order_items_on_item"
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
    t.bigint "organization_id"
    t.integer "status", default: 0
    t.bigint "user_id"
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["organization_id"], name: "index_orders_on_organization_id"
    t.index ["table_id"], name: "index_orders_on_table_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "logo"
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at"
    t.index ["phone"], name: "index_organizations_on_phone", unique: true
    t.index ["user_id"], name: "index_organizations_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tables", force: :cascade do |t|
    t.string "name"
    t.integer "chairs"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.index ["deleted_at"], name: "index_tables_on_deleted_at"
    t.index ["organization_id"], name: "index_tables_on_organization_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.string "color_header"
    t.string "color_sidebar"
    t.string "color_footer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_themes_on_organization_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "avatar"
    t.bigint "organization_id"
    t.bigint "role_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "wine_styles", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_wine_styles_on_deleted_at"
    t.index ["name"], name: "index_wine_styles_on_name", unique: true
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
    t.bigint "organization_id"
    t.bigint "wine_style_id"
    t.index ["deleted_at"], name: "index_wines_on_deleted_at"
    t.index ["maker_id"], name: "index_wines_on_maker_id"
    t.index ["organization_id"], name: "index_wines_on_organization_id"
    t.index ["wine_style_id"], name: "index_wines_on_wine_style_id"
  end

  add_foreign_key "allowlisted_jwts", "users", on_delete: :cascade
  add_foreign_key "beers", "beer_styles"
  add_foreign_key "beers", "makers"
  add_foreign_key "beers", "organizations"
  add_foreign_key "dish_ingredients", "dishes"
  add_foreign_key "dish_ingredients", "foods"
  add_foreign_key "dishes", "organizations"
  add_foreign_key "drinks", "makers"
  add_foreign_key "drinks", "organizations"
  add_foreign_key "foods", "organizations"
  add_foreign_key "makers", "organizations"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "organizations"
  add_foreign_key "orders", "tables"
  add_foreign_key "orders", "users"
  add_foreign_key "organizations", "users"
  add_foreign_key "tables", "organizations"
  add_foreign_key "themes", "organizations"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "roles"
  add_foreign_key "wines", "makers"
  add_foreign_key "wines", "organizations"
  add_foreign_key "wines", "wine_styles"
end
