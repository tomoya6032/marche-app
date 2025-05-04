class AddHostIdToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :host_id, :bigint
    add_index :events, :host_id
    add_foreign_key :events, :hosts
  end
end
