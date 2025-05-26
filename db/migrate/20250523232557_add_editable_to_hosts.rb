class AddEditableToHosts < ActiveRecord::Migration[8.0]
  def change
    add_column :hosts, :editable, :boolean, default: true
  end
end
