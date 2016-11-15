class AddLastPriceToAlert < ActiveRecord::Migration
  def change
    add_column :alerts, :last_price, :float
  end
end
