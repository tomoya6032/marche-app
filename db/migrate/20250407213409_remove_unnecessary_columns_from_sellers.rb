class RemoveUnnecessaryColumnsFromSellers < ActiveRecord::Migration[8.0]
  def change
    remove_column :sellers, :latitude, :float
    remove_column :sellers, :longitude, :float
    remove_column :sellers, :profile_type, :integer
  end
end
