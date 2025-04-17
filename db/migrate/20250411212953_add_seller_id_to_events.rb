class AddSellerIdToEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :events, :seller, foreign_key: true
  end
end
