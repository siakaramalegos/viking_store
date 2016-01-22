class User < ActiveRecord::Base
  has_many :addresses, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: proc { |attributes| deep_blank?(attributes) }

  has_many :credit_cards, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :carts, dependent: :destroy

  # TODO: create last_order association to reduce N+1?
  # has_one :last_order, class_name: 'Order', order: 'checkout_date DESC', limit: 1

  has_many :products, through: :orders

  belongs_to :default_shipping_address, foreign_key: :shipping_id, class_name: 'Address'
  belongs_to :default_billing_address, foreign_key: :billing_id, class_name: 'Address'

  validates :first_name, :last_name, :email, presence: true, length: {in: 1..64}

  validates_confirmation_of :email

  scope :day_range, -> (start_day, end_day) {where("created_at >= ? AND created_at <= ?", start_day.days.ago, end_day.days.ago)}

  # Recursively traverse nested attributes to define is all values blank.
  # Additionaly considers that value with _destroy key is always blank.
  # https://github.com/rails/rails/pull/23001
  def self.deep_blank?(hash)
    hash.each do |key, value|
      next if key == '_destroy'
      any_blank = value.is_a?(Hash) ? deep_blank?(value) : value.blank?
      return false unless any_blank
    end
    true
  end

  def name
    "#{first_name} #{last_name}"
  end

  def last_order
    self.orders.order("checkout_date DESC").limit(1).first
  end

  # Join clause to join users with order_totals table
  def self.user_order_totals_join(days_ago = nil)
    "JOIN (#{Order.order_totals_query(days_ago)}) ot ON ot.user_id = users.id"
  end

  # Returns first_name, last_name, revenue for each order
  def self.user_order_totals(days_ago = nil)
    User.select("users.first_name, users.last_name, ot.revenue as amount").joins(user_order_totals_join)
  end

  def self.get_highest_order_user
    user_order_totals.order("amount DESC").limit(1)[0]
  end

  def self.get_highest_aggregation_user(aggregator)
    User.select("users.first_name, users.last_name, #{aggregator}(ot.revenue) as amount").joins(user_order_totals_join).group("users.id").order("amount DESC").limit(1)[0]
  end
end
