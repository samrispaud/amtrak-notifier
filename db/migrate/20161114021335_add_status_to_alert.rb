class AddStatusToAlert < ActiveRecord::Migration
  def change
    add_column :alerts, :status, :string
  end
end
