class AddFacilityIdToSellers < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :facility_id, :bigint
    add_index :sellers, :facility_id
    add_foreign_key :sellers, :facilities
  end
end
