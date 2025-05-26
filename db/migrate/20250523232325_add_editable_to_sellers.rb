class AddEditableToSellers < ActiveRecord::Migration[8.0]
  def change
    add_column :sellers, :editable, :boolean, default: true
  end
end
