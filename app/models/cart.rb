class Cart < ActiveRecord::Base
  belongs_to :user

  has_many :order_contents, dependent: :destroy
  accepts_nested_attributes_for :order_contents, reject_if: :all_blank, allow_destroy: true

  has_many :products, through: :order_contents

  validates_uniqueness_of :user_id, allow_nil: true

  def add_product(product_id, quantity = 1)
    product = Product.find(product_id)
    current_item = order_contents.find_by(product_id: product.id)
    if current_item
      current_item.quantity += quantity
    else
      current_item = order_contents.build(product: product, price: product.price, quantity: quantity)
    end
    current_item
  end

  def subtotal
    order_contents.select("SUM(quantity * price)")[0].sum.round(2)
  end

  def tax
    (subtotal * 0.1).round(2)
  end

  def shipping
    (subtotal * 0.1).round(2)
  end

  def grand_total
    subtotal + tax + shipping
  end
end
