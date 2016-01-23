class CartsController < ApplicationController
  include CurrentCart
  before_action :set_cart

  def edit
    @cart = Cart.includes(:order_contents => :product).find(@cart.id)
  end

  def update
    # TODO: if item quantity = 0, remove from cart
    if @cart.update(cart_params)
      redirect_to edit_cart_url, notice: 'Cart successfully updated.'
    else
      flash.now[:alert] = 'There was a problem updating your cart.'
      render :edit
    end
  end

  private

  def cart_params
    params.require(:cart).permit({ :order_contents_attributes => [:id, :quantity, :_destroy] })
  end
end
