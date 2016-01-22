namespace :db do
  desc 'Clear the database and fill with excellent fake data'
  task :populate => :environment do
    require 'populator'
    require 'faker'

    puts "Starting populator...\n\n"
    start_time = Time.now
    MULTIPLIER = 5




    # Blow away the existing data
    puts "Removing old data..."
    tables = [OrderContent, Order, Cart, CreditCard, Address, Product, User, Category, City]

    tables.each do |table|
      table.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(table.table_name)
    end
    puts "Old data removed.\n\n"




    # Cities
    puts "Creating Cities..."
    City.populate(MULTIPLIER * 50) do |city|
      city.name = Faker::Address.city
    end
    puts "Cities created.\n\n"

    # Building range for future reference
    city_arr = (City.first.id..City.last.id).to_a
    state_arr = (State.first.id..State.last.id).to_a

    # Weighting first 4 cities and states more heavily
    4.times do |i|
      3.times{city_arr << city_arr[i]}
      3.times{state_arr << state_arr[i]}
    end




    # Users, Credit Cards, Addresses
    puts "Creating users, credit cards, and addresses..."

    # Weighted array of days ago for user join date
    days_ago_arr = []
    365.times do |i|
      (364-i).times{days_ago_arr << i+1}
    end
    days_ago_arr.shuffle!

    User.populate(MULTIPLIER * 23) do |user|
      user.email = Faker::Internet.email
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.phone_number = Faker::PhoneNumber.phone_number
      user.created_at = Faker::Time.between(DateTime.now - days_ago_arr.pop, DateTime.now)

      CreditCard.populate(1..3) do |card|
        card.user_id = user.id
        card.name_on_card = "#{user.first_name} #{user.last_name}"
        card.card_number = Faker::Business.credit_card_number
        card.exp_month = rand(1..12)
        card.exp_year = rand(2016..2020)
        card.brand = Faker::Business.credit_card_type
        card.nickname = "My #{card.brand} card"
        card.ccv = rand(111..999).to_s
      end # Credit Card

      Address.populate(0..5) do |address|
        user.billing_id = address.id
        user.shipping_id = address.id
        address.user_id = user.id
        address.street_address = Faker::Address.street_address
        if rand(1..3) == 3
          address.secondary_address = Faker::Address.secondary_address
        end
        address.city_id = city_arr.sample
        address.state_id = state_arr.sample
        address.zip_code = Faker::Address.zip_code
      end # Address
    end # User
    puts "Users, credit cards, and addresses created.\n\n"




    # Categories and Products
    puts "Creating categories and products..."
    Category.populate(MULTIPLIER * 3) do |category|
      category.name = Faker::Commerce.department
      category.description = Faker::Lorem.sentence

      Product.populate(10..30) do |product|
        product.name = Faker::Commerce.product_name
        product.description = Faker::Company.bs
        product.category_id = category.id
        product.price = Faker::Commerce.price
        product.sku = Faker::Code.ean
      end # Product
    end # Category
    puts "Categories and products created.\n\n"




    # Orders
    puts "Creating orders and associated contents..."
    product_range = (Product.first.id..Product.last.id)
    Order.populate(MULTIPLIER * 20) do |order|
      address = Address.all.sample
      user = User.find(address.user_id)
      order.user_id = user.id
      order.shipping_id = address.id
      order.billing_id = address.id
      order.credit_card_id = CreditCard.find_by_user_id(user.id)
      order.created_at = Faker::Time.between(DateTime.now - days_ago_arr.pop, DateTime.now)

      OrderContent.populate(1..5) do |item|
        product = Product.find(rand(product_range))
        item.product_id = product.id
        item.quantity = rand(1..3)
        item.price = product.price
        item.order_id = order.id
      end # Line Item

    end # Order
    puts "Orders with contents created.\n\n"




    # Carts
    puts "Creating carts and associated contents..."

    User.all.each do |user|
      next if rand(1..3) != 3
      Cart.populate(1) do |cart|
        cart.user_id = user.id

        OrderContent.populate(1..5) do |item|
          product = Product.find(rand(product_range))
          item.product_id = product.id
          item.quantity = rand(1..3)
          item.price = product.price
          item.cart_id = cart.id
        end # Line Item
      end # Cart
    end # User
    puts "Carts with contents created.\n\n"

    puts "ALL DONE! ...in #{Time.now - start_time} seconds."
  end
end