class CreditCard < ActiveRecord::Base
  belongs_to :user
  has_many :orders, dependent: :nullify

  validates :card_number, length: {is: 16}

  BRANDS = ['VISA', 'AMEX', 'MASTERCARD', 'DISCOVER']
  validates :brand, inclusion: { in: BRANDS }

  MONTHS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  validates :exp_month, inclusion: { in: MONTHS }

  YEARS = []
  10.times { |i| YEARS << Time.now.year + i }
  validates :exp_year, inclusion: { in: YEARS }

  def expiration
    "#{exp_month}/#{exp_year}"
  end

  def last_4_digits
    card_number[-4..-1]
  end

  def short_description
    "#{nickname}: #{brand.upcase} ****#{last_4_digits}"
  end
end
