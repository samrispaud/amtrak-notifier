class AddUserToAlert < ActiveRecord::Migration
  def change
    add_reference :alerts, :user, index: true, foreign_key: true
  end
end
