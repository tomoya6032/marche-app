class AllowNullNameToAdmins < ActiveRecord::Migration[8.0]
  def change
    change_column_null :admins, :name, true
  end
end
