class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_one :alert
  validates :ticker, presence: true
  validates :quantity, presence: true
  validates :order_type, presence: true
  validates :user, presence: true
  validates :game, presence: true
  mount_uploader :receipt, OrderReceiptUploader
end
