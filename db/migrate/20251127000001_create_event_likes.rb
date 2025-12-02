class CreateEventLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :event_likes do |t|
      t.references :event, null: false, foreign_key: true
      t.string :visitor_token
      t.bigint :seller_id
      t.bigint :host_id

      t.timestamps
    end

    add_index :event_likes, [:event_id, :visitor_token]
    add_index :event_likes, [:event_id, :seller_id]
    add_index :event_likes, [:event_id, :host_id]
  end
end
