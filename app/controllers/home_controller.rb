class HomeController < ApplicationController
  
  
  
  def index
     # 注目イベントを取得
    @featured_events = Event.where(is_featured: true).page(params[:page]).per(5) # 1ページに5件表示
    @recent_events = Event.order(start_time: :asc).limit(5) # 注目ピックアップカテゴリのイベントを取得
    @facilities = Facility.all
    @recent_events = Event.where('start_time >= ?', Date.today).order(start_time: :asc) # 例: 近日開催のイベントを取得
    @notices = Notice.order(published_at: :desc).limit(5) # 最新5件のお知らせを取得
    # 必要に応じて `host_signed_in?` を使用
    if host_signed_in?
      @host = current_host
    end
  end


  def recruitment
    # 必要に応じてデータを取得
  end



end
