class HomeController < ApplicationController
  def index
    # render 'home/index'
    @recent_events = Event.where('start_time >= ?', Time.current)
      .order(:start_time)
      .limit(3) # 最新の3件を表示する場合
  end
end