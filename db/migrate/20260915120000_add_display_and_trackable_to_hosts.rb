class AddDisplayAndTrackableToHosts < ActiveRecord::Migration[8.0]
  def change
    add_column :hosts, :display_in_list, :boolean, default: true, null: false
    add_index :hosts, :display_in_list

    add_column :hosts, :sign_in_count, :integer, default: 0, null: false
    add_column :hosts, :current_sign_in_at, :datetime
    add_column :hosts, :last_sign_in_at, :datetime
    add_column :hosts, :current_sign_in_ip, :string
    add_column :hosts, :last_sign_in_ip, :string
  end
end