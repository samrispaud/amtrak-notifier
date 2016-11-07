class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  validates :ticker, presence: true
  validates :quantity, presence: true
  validates :order_type, presence: true
end
