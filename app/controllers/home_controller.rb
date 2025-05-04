class HomeController < ApplicationController
  def index
@facilities = Facility.all
    @recent_events = Event.order(start_time: :asc).limit(5) # 例: 近日開催のイベントを取得

    # 必要に応じて `host_signed_in?` を使用
    if host_signed_in?
      @host = current_host
    end
  end
end
