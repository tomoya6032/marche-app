class AddMissingColumnsToAdmins < ActiveRecord::Migration[8.0]
  def change
    add_column :admins, :encrypted_password, :string, null: false, default: "" unless column_exists?(:admins, :encrypted_password)
    add_column :admins, :role, :string, null: false, default: "admin" unless column_exists?(:admins, :role)
    add_column :admins, :active, :boolean, null: false, default: true unless column_exists?(:admins, :active)
    add_column :admins, :reset_password_token, :string unless column_exists?(:admins, :reset_password_token)
    add_column :admins, :reset_password_sent_at, :datetime unless column_exists?(:admins, :reset_password_sent_at)
    add_column :admins, :remember_created_at, :datetime unless column_exists?(:admins, :remember_created_at)

    add_index :admins, :reset_password_token, unique: true unless index_exists?(:admins, :reset_password_token)
  end
end
