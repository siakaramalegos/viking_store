class OrdersController < ApplicationController
  include CurrentCart
  before_action :authenticate_user!
  before_action :set_cart, only: [:new]

  def new
    @order = current_user.orders.build
    @cart = Cart.includes(:order_contents => :product).find(@cart.id)
    @user = User.where(id: current_user.id).includes(:credit_cards, :addresses => [:city, :state]).first
    @order.build_credit_card
  end

  def update

  end

  private

  def order_params
    params.require(:order).permit(:shipping_id, :billing_id, :credit_card_id, { :credit_card_attributes => [:nickname, :name_on_card, :card_number, :brand, :exp_month, :exp_year] })
  end
end
