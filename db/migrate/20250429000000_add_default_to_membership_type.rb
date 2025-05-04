class AddDefaultToMembershipType < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:users, :membership_type)
      change_column_default :users, :membership_type, from: nil, to: 0
    end
  end
end
