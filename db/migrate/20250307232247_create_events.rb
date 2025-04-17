class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.string :venue
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :capacity
      t.boolean :is_online
      t.string :online_url
      t.boolean :is_free
      t.string :price
      t.string :organizer
      t.string :contact_info
      t.string :website
      t.integer :status
      t.string :image
      t.string :video
      t.integer :category_id
      t.integer :facility_id

      t.timestamps
    end
  end
end
