class HomeController < ApplicationController
  before_action :set_og_image, only: [:features, :pricing, :plan_comparison]
  
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
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "出店者募集", path: recruitment_path}]
  end

  def features
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "機能一覧", path: features_path}]
  end

  def pricing
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "利用料金", path: pricing_path}]
  end

  def plan_comparison
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "プラン比較", path: plan_comparison_path}]
  end

  def flow
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "掲載までの流れ", path: flow_path}]
  end

  def use_cases
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "利用事例", path: use_cases_path}]
  end

  def terms
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "利用規約", path: terms_path}]
  end

  def privacy
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "プライバシーポリシー", path: privacy_path}]
  end

  def commercial_law
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "特定商取引法に基づく表示", path: commercial_law_path}]
  end

  private

  # Set @og_image to use the dynamic OGP endpoint for supported pages.
  # This generates optimized 1200x630 OGP images from hero images.
  def set_og_image
    if %w[features pricing plan_comparison].include?(action_name)
      @og_image = og_image_url(page: action_name, format: :jpg)
    else
      # Fallback to static asset for other pages
      @og_image = view_context.asset_url('marchelogo2.png')
    end
  end
end
