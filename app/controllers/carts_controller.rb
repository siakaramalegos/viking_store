class CartsController < ApplicationController
  include CurrentCart
  before_action :set_cart

  def edit
    @cart = Cart.includes(:order_contents => :product).find(@cart.id)
  end

  def update

  end

  private

  def cart_params
    params.require(:order).permit({ :order_contents_attributes => [:id, :quantity, :_destroy] })
  end
end
