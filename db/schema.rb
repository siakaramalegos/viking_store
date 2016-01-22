# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160122191645) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer  "user_id",           null: false
    t.string   "street_address",    null: false
    t.string   "secondary_address"
    t.integer  "city_id",           null: false
    t.integer  "state_id",          null: false
    t.string   "zip_code",          null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "addresses", ["city_id"], name: "index_addresses_on_city_id", using: :btree
  add_index "addresses", ["state_id"], name: "index_addresses_on_state_id", using: :btree
  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "credit_cards", force: :cascade do |t|
    t.integer  "user_id",                                 null: false
    t.string   "nickname",     default: "My Credit Card"
    t.string   "name_on_card",                            null: false
    t.string   "card_number",                             null: false
    t.string   "brand",        default: "VISA"
    t.integer  "exp_month",                               null: false
    t.integer  "exp_year",                                null: false
    t.string   "ccv"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "credit_cards", ["user_id"], name: "index_credit_cards_on_user_id", using: :btree

  create_table "order_contents", force: :cascade do |t|
    t.integer  "product_id",             null: false
    t.integer  "quantity",   default: 1, null: false
    t.integer  "order_id",               null: false
    t.decimal  "price",                  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "cart_id"
  end

  add_index "order_contents", ["cart_id"], name: "index_order_contents_on_cart_id", using: :btree
  add_index "order_contents", ["order_id"], name: "index_order_contents_on_order_id", using: :btree
  add_index "order_contents", ["product_id"], name: "index_order_contents_on_product_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "checkout_date"
    t.integer  "shipping_id"
    t.integer  "billing_id"
    t.integer  "credit_card_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "orders", ["billing_id"], name: "index_orders_on_billing_id", using: :btree
  add_index "orders", ["credit_card_id"], name: "index_orders_on_credit_card_id", using: :btree
  add_index "orders", ["shipping_id"], name: "index_orders_on_shipping_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "description"
    t.integer  "category_id"
    t.decimal  "price",       null: false
    t.string   "sku"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "abbreviation", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",        null: false
    t.string   "first_name",   null: false
    t.string   "last_name",    null: false
    t.string   "phone_number"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "billing_id"
    t.integer  "shipping_id"
  end

  add_foreign_key "addresses", "cities"
  add_foreign_key "addresses", "states"
  add_foreign_key "addresses", "users"
  add_foreign_key "carts", "users"
  add_foreign_key "credit_cards", "users"
  add_foreign_key "order_contents", "carts"
  add_foreign_key "order_contents", "orders"
  add_foreign_key "order_contents", "products"
  add_foreign_key "orders", "addresses", column: "billing_id"
  add_foreign_key "orders", "addresses", column: "shipping_id"
  add_foreign_key "orders", "credit_cards"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "categories"
end
