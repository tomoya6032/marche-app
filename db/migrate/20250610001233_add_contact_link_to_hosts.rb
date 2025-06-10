class AddContactLinkToHosts < ActiveRecord::Migration[8.0]
  def change
    add_column :hosts, :contact_link, :string
  end
end
