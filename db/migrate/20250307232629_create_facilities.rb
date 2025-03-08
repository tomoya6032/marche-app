class CreateFacilities < ActiveRecord::Migration[8.0]
  def change
    create_table :facilities do |t|
      t.string :name
      t.text :description
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :phone_number
      t.string :email
      t.string :website
      t.integer :facility_type
      t.string :image
      t.string :video

      t.timestamps
    end
  end
end
