class OrderContentsController < ApplicationController
  include CurrentCart
  before_action :set_cart

  def create
    product = Product.find(params[:product_id])
    @line_item = @cart.add_product(product.id)
    if @line_item.save
      redirect_to products_index_url, notice: "Product successfully added to cart."
    else
      redirect_to products_index_url, alert: "The product could not be added to your cart."
    end
  end
end
