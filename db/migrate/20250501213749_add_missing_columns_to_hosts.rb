class AddMissingColumnsToHosts < ActiveRecord::Migration[8.0]
  def change
    add_column :hosts, :name, :string
    add_column :hosts, :description, :text
    add_column :hosts, :address, :string
    add_column :hosts, :phone_number, :string
    add_column :hosts, :website, :string
    add_column :hosts, :image, :string
    add_column :hosts, :video, :string
    add_column :hosts, :business_hours_days, :string
    add_column :hosts, :business_hours_start, :time
    add_column :hosts, :business_hours_end, :time
    add_column :hosts, :past_exhibitions_names, :text
    add_column :hosts, :past_exhibitions_dates, :text
    add_column :hosts, :sns_accounts_types, :text
    add_column :hosts, :sns_accounts_urls, :text
  end
end
