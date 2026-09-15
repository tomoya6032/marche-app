class AddDisplayAndTrackableToSellers < ActiveRecord::Migration[8.0]
  def change
    add_column :sellers, :display_in_list, :boolean, default: true, null: false
    add_index :sellers, :display_in_list

    add_column :sellers, :sign_in_count, :integer, default: 0, null: false
    add_column :sellers, :current_sign_in_at, :datetime
    add_column :sellers, :last_sign_in_at, :datetime
    add_column :sellers, :current_sign_in_ip, :string
    add_column :sellers, :last_sign_in_ip, :string
  end
end