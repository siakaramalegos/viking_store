class Address < ActiveRecord::Base
  belongs_to :user
  belongs_to :state
  belongs_to :city, autosave: true
  accepts_nested_attributes_for :city

  has_one :user_default_shipping, foreign_key: :shipping_id, class_name: 'User', dependent: :nullify
  has_one :user_default_billing, foreign_key: :billing_id, class_name: 'User', dependent: :nullify

  has_many :ship_to_orders, foreign_key: :shipping_id, class_name: 'Order', dependent: :nullify
  has_many :bill_to_orders, foreign_key: :billing_id, class_name: 'Order', dependent: :nullify

  validates :street_address, :state_id, :zip_code, presence: true
  validates_associated :city

  def city_state_zip
    "#{city.name}, #{state.abbreviation}  #{zip_code}"
  end

  def one_line
    if secondary_address
      "#{street_address}, #{secondary_address}, #{city.name}, #{state.abbreviation}"
    else
      "#{street_address}, #{city.name}, #{state.abbreviation}"
    end
  end

  def autosave_associated_records_for_city
    if new_city = City.find_by_name(city.name)
      self.city = new_city
    else
      city.save!
      self.city = city
    end
  end
end
