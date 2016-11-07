class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.text :ticker
      t.integer :quantity
      t.text :order_type
      t.text :status
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
