class AddIsFeaturedToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :is_featured, :boolean, default: false, null: false
  end
end
