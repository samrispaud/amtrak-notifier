class ChangeOrderTypeToType < ActiveRecord::Migration
  def change
    rename_column :orders, :order_type, :type
  end
end
