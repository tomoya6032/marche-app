class AddColumnsToSellersForAdditionalInfo < ActiveRecord::Migration[8.0]
  def change
    add_column :sellers, :business_hours_days, :string
    add_column :sellers, :business_hours_start, :time
    add_column :sellers, :business_hours_end, :time
    add_column :sellers, :past_exhibitions_names, :text
    add_column :sellers, :past_exhibitions_dates, :text
    add_column :sellers, :sns_accounts_types, :text
    add_column :sellers, :sns_accounts_urls, :text
  end
end