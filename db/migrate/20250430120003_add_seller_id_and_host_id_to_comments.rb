class AddSellerIdAndHostIdToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :seller_id, :bigint
    add_column :comments, :host_id, :bigint
  end
end
