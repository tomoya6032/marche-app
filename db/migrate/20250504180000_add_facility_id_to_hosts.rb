class AddFacilityIdToHosts < ActiveRecord::Migration[6.1]
  def change
    add_column :hosts, :facility_id, :bigint
    add_index :hosts, :facility_id
    add_foreign_key :hosts, :facilities
  end
end
