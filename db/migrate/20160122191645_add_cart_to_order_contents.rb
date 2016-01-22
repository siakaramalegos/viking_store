class AddCartToOrderContents < ActiveRecord::Migration
  def change
    add_reference :order_contents, :cart, index: true, foreign_key: true
  end
end
