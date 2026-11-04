class AddShowTrialPeriodExpiredNoticeToSiteSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :site_settings, :show_trial_period_expired_notice, :boolean, default: true, null: false
  end
end
