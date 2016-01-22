class Admin::DashboardController < AdminController
  def index
    # Panel 1: Overall Platform
    @overall_7_days = get_overall_stats(7)
    @overall_30_days = get_overall_stats(30)
    @overall_total = get_overall_stats

    # Panel 2: User Demographics and Behavior
    @top_states = State.top_3_summary
    @top_cities = City.top_3_summary
    @behavior_stats = get_behavior_stats

    # Panel 3: Order Statistics
    @order_stats_7_days = Order.get_order_stats(7)
    @order_stats_30_days = Order.get_order_stats(30)
    @order_stats_total = Order.get_order_stats

    # Panel 4: Time Series Data
    @orders_by_day = Order.get_orders_by_time('day')
    @orders_by_week = Order.get_orders_by_time('week')
  end

  private

  def get_overall_stats(days_ago = nil)
    if days_ago
      days_ago == 7 ? change_start = 14 : change_start = 60
      {
        current: period_values(days_ago, 0),
        previous: period_values(change_start, days_ago + 1)
      }
    else
      {
          num_users: User.all.count,
          num_orders: Order.all.count,
          num_products: Product.all.count,
          total_revenue: Order.get_revenue
      }
    end
  end

  def period_values(start_day, end_day)
    if end_day == 0
      revenue = Order.get_revenue(start_day)
    else
      revenue = Order.get_revenue(start_day) - Order.get_revenue(end_day - 1)
    end

    {
      num_users: User.day_range(start_day,end_day).count,
      num_orders: Order.day_range(start_day,end_day).count,
      num_products: Product.day_range(start_day,end_day).count,
      total_revenue: revenue
    }
  end

  def get_behavior_stats
    [
      {criteria: 'Highest Single Order Value',
        result: User.get_highest_order_user,
        currency: true},
      {criteria: 'Highest Lifetime Value',
        result: User.get_highest_aggregation_user('SUM'),
        currency: true},
      {criteria: 'Highest Average Order Value',
        result: User.get_highest_aggregation_user('AVG'),
        currency: true},
      {criteria: 'Most Orders Placed',
        result: User.get_highest_aggregation_user('COUNT'),
        currency: false}
    ]
  end
end
