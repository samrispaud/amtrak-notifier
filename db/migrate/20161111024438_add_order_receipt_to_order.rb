class AddOrderReceiptToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :receipt, :string
  end
end
