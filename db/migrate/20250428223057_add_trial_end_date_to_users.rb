class AddTrialEndDateToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :trial_end_date, :date
  end
end
