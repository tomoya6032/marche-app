class AddColumnsToSellers < ActiveRecord::Migration[8.0]
  def change
    add_column :sellers, :name, :string
    add_column :sellers, :description, :text
    add_column :sellers, :address, :string
    add_column :sellers, :latitude, :float
    add_column :sellers, :longitude, :float
    add_column :sellers, :phone_number, :string
    add_column :sellers, :website, :string
    add_column :sellers, :profile_type, :integer
    add_column :sellers, :image, :string
    add_column :sellers, :video, :string
  end
end
