class RemoveForeignKeyFromCommentsToUsers < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :comments, :users
    change_column_null :comments, :user_id, true
  end
end