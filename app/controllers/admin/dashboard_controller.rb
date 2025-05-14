# app/controllers/admin/dashboard_controller.rb (例)
class Admin::DashboardController < Admin::BaseController # Admin::BaseController が存在すると仮定
  def index
    @total_sellers = Seller.count
    @total_hosts = Host.count
    @total_events = Event.count
    @recent_sellers = Seller.order(created_at: :desc).limit(5)
    @recent_hosts = Host.order(created_at: :desc).limit(5)
    @recent_events = Event.order(created_at: :desc).limit(5)
  end
end