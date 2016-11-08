class AddStockfusePasswordColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :stockfuse_password, :text
  end
end
