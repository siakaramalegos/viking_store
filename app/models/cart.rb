class Cart < ActiveRecord::Base
  belongs_to :user

  has_many :order_contents, dependent: :destroy
  accepts_nested_attributes_for :order_contents, reject_if: :all_blank, allow_destroy: true

  has_many :products, through: :order_contents

  validates_uniqueness_of :user_id
end
