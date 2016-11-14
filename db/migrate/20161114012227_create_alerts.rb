class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string :ticker
      t.string :exchange
      t.string :comparison_logic
      t.float :price
      t.references :order, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
