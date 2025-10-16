class HomeController < ApplicationController
  def index
    # 注目イベントを取得（画像のみ必要なのでsellerとhostのincludesを削除）
    @featured_events = Event.includes(images_attachments: :blob)
                           .where(is_featured: true)
                           .page(params[:page])
                           .per(5)

    # 最近のイベントを取得（画像のみ必要なのでsellerとhostのincludesを削除）
    @recent_events = Event.includes(images_attachments: :blob)
                          .where("start_time >= ?", Time.zone.now)
                          .order(start_time: :asc)
                          .limit(5)

    # @facilities は使用されていないためコメントアウト
    # @facilities = Facility.all

    # お知らせを取得
    @notices = Notice.order(published_at: :desc).limit(5)

    # 直近1週間で人気のイベント上位3つを取得（N+1対策でincludesを直接使用）
    @popular_events = Event.popular_this_week(3)

    # 必要に応じて `host_signed_in?` を使用
    if host_signed_in?
      @host = current_host
    end
  end


  def recruitment
    # 必要に応じてデータを取得
  end

  def features
    # 機能一覧ページ
  end

  def pricing
    # 料金についてページ
  end

  def plan_comparison
    # プラン比較ページ
  end

  def flow
    # 掲載までの流れページ（既存のrecruitmentページを改修）
  end

  def use_cases
    # 利用事例ページ
  end

  def terms
    # 利用規約ページ
  end

  def privacy
    # プライバシーポリシーページ
  end

  def commercial_law
    # 特定商取引法に基づく表示ページ
  end
end
