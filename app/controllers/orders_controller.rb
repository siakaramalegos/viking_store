class OrdersController < ApplicationController
  include CurrentCart
  before_action :authenticate_user!
  before_action :set_cart, only: [:new]

  def new
    @order = current_user.orders.build
    @cart = Cart.includes(:order_contents => :product).find(@cart.id)
    @user = User.where(id: current_user.id).includes(:credit_cards, :addresses => [:city, :state]).first
  end

  def update

  end

  private

  def order_params
    params.require(:order).permit({ :order_contents_attributes => [:id, :quantity, :_destroy] })
  end
end
