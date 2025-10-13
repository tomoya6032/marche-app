class CreateEventViews < ActiveRecord::Migration[8.0]
  def change
    create_table :event_views do |t|
      t.references :event, null: false, foreign_key: true
      t.string :ip_address
      t.datetime :viewed_at

      t.timestamps
    end

    add_index :event_views, [ :event_id, :ip_address, :viewed_at ]
    add_index :event_views, :viewed_at
  end
end
