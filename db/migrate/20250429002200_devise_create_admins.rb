class DeviseCreateAdmins < ActiveRecord::Migration[6.1]
  def change
    create_table :admins do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: "" # 必須カラム

      ## Additional fields
      t.string :name, null: false
      t.string :role, null: false, default: "admin"
      t.boolean :active, null: false, default: true

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :admins, :email, unique: true
    add_index :admins, :reset_password_token, unique: true
  end
end
