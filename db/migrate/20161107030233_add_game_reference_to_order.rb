class AddGameReferenceToOrder < ActiveRecord::Migration
  def change
    add_reference :orders, :game, index: true
  end
end
