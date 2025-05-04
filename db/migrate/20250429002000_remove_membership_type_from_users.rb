class RemoveMembershipTypeFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :membership_type, :integer
  end
end
