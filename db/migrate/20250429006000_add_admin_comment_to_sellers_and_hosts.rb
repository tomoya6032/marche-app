class AddAdminCommentToSellersAndHosts < ActiveRecord::Migration[8.0]
  def change
    add_column :sellers, :admin_comment, :text
    add_column :hosts, :admin_comment, :text
  end
end
