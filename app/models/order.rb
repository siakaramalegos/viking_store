class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :credit_card
  accepts_nested_attributes_for :credit_card, reject_if: :all_blank

  belongs_to :shipping_address, foreign_key: :shipping_id, class_name: 'Address'
  belongs_to :billing_address, foreign_key: :billing_id, class_name: 'Address'

  has_many :order_contents, dependent: :destroy
  accepts_nested_attributes_for :order_contents, reject_if: :all_blank, allow_destroy: true

  has_many :products, through: :order_contents
  has_many :categories, through: :products

  validates :billing_id, :shipping_id, :credit_card_id,
    :presence => true,
    :unless => Proc.new{ checkout_date.nil? }

  # TODO: validates addresses and credit cards are in order.user's list
  # validates_associated :billing_id, :shipping_id, inclusion: {in: user.address_ids}
  # validates_associated :credit_card_id, inclusion: {in: user.credit_card_ids}

  scope :days_ago, -> (days_past = 7) { where("orders.created_at >= ?", days_past.days.ago) }
  scope :day_range, -> (start_day, end_day) {where("orders.created_at >= ? AND created_at <= ?", start_day.days.ago, end_day.days.ago)}

  def order_value
    self.order_contents.select("SUM(quantity * price)")[0].sum
  end

  def order_quantity
    self.order_contents.select("SUM(quantity)")[0].sum
  end

  def self.get_orders_by_time(time_frame)
    if time_frame == 'day'
      date_field = "o.created_at"
      days_ago = 7
    elsif time_frame == 'week'
      date_field = "date_trunc('week', o.created_at)"
      days_ago = 49
    end

    date_series = "
      SELECT DISTINCT date(date_trunc('#{time_frame}', current_date - s.a)) as date FROM generate_series(0,#{days_ago},1) as s(a) ORDER BY date DESC"

    actual_data_series = "
      SELECT date(#{date_field}) as date, COUNT(DISTINCT o.id) as quantity, SUM(oc.quantity * oc.price) as value
      FROM orders o
        JOIN order_contents oc ON oc.order_id = o.id
      WHERE date(o.created_at) >= date(?)
      GROUP BY date
      ORDER BY date DESC
      LIMIT 7"

    query = "
      SELECT e.date, COALESCE(a.quantity, 0) as quantity, COALESCE(a.value, 0) as value
      FROM (#{date_series}) e
        LEFT JOIN (#{actual_data_series}) a ON a.date = e.date;"

    Order.find_by_sql([query, days_ago.days.ago])
  end

  def self.get_order_stats(days_ago = nil)
    if days_ago
      {
        num_orders: Order.days_ago(days_ago).count,
        total_revenue: Order.get_revenue(days_ago),
        avg_order_value: Order.get_aggregation_order('AVG', days_ago),
        max_order_value: Order.get_aggregation_order('MAX', days_ago)
      }
    else
      {
        num_orders: Order.all.count,
        total_revenue: Order.get_revenue(days_ago),
        avg_order_value: Order.get_aggregation_order('AVG'),
        max_order_value: Order.get_aggregation_order('MAX')
      }
    end
  end

  def self.get_revenue(days_ago = nil)
    select_revenue = "SUM(oc.price * oc.quantity) as revenue"
    join = "JOIN order_contents oc ON oc.order_id = orders.id"
    if days_ago
      relation = Order.select(select_revenue).joins(join).days_ago(days_ago)
    else
      relation = Order.select(select_revenue).joins(join)
    end
    revenue = relation[0].revenue
    revenue ? revenue : 0
  end

  def self.get_aggregation_order(aggregator, days_ago = nil)
    query = aggregate_order_query(aggregator, days_ago)
    Order.find_by_sql(query)[0].amount
  end

  def self.aggregate_order_query(aggregator, days_ago = nil)
    "SELECT #{aggregator}(revenue) as amount
    FROM (#{order_totals_query(days_ago)}) ot"
  end

  # Returns order_id as id, user_id, revenue
  def self.order_totals_query(days_ago = nil)
    if days_ago
      where_clause = ">= '#{days_ago.days.ago}'"
    else
      where_clause = "IS NOT NULL"
    end

    "SELECT o.id, o.user_id, SUM(oc.price * oc.quantity) as revenue
      FROM orders o
        JOIN order_contents oc ON oc.order_id = o.id
      WHERE o.created_at #{where_clause}
      GROUP BY o.id"
  end

end
