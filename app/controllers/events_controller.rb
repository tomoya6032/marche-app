class EventsController < ApplicationController
  before_action :authenticate_seller!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]
  before_action :set_prefectures, only: [ :index, :new, :edit, :create ]

  include ActionController::Helpers
  include ActionView::Helpers::AssetUrlHelper


  def index
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "イベント一覧", path: events_path}]
    # 基本のイベント取得
    @events = Event.includes(:host, :seller, images_attachments: :blob)
    # フィルタリング: 開催日の近い順
    if params[:filter] == "recent"
      now = Time.zone.now
      @events = @events.where("start_time >= ?", now)
                      .order(start_time: :asc)
      # sortパラメータがある場合は後で上書きされる
    end

    # フィルタリング: 都道府県
    if params[:prefecture].present?
      @events = @events.where(venue: params[:prefecture])
    end

    # ★★★ 並び替え処理の修正：新しいソートオプションを追加 ★★★
    case params[:sort]
    when "start_time_asc"
      @events = @events.order(Arel.sql("DATE(start_time) ASC, start_time ASC"))
    when "start_time_desc"
      @events = @events.order(Arel.sql("DATE(start_time) DESC, start_time DESC"))
    when "upcoming_first" # ★修正：未開催かつ開催日が近い順
      now = Time.zone.now
      # 1. 未開催のイベントのみ取得
      # 2. 開催日が近い順（昇順）で並べる
      @events = @events.where("start_time >= ?", now)
                      .order(start_time: :asc)
    when "recent" # ★追加：開催日が近い順（未開催のみ）
      now = Time.zone.now
      # 未開催のイベントを開催日が近い順で表示
      @events = @events.where("start_time >= ?", now)
                      .order(start_time: :asc)
    when "created_at_desc", nil, ""
      @events = @events.order(created_at: :desc)
    else
      @events = @events.order(created_at: :desc)
    end

    # ★★★ ページネーションを最後に適用 ★★★
    @events = @events.page(params[:page]).per(10)
  end

  def show
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "イベント一覧", path: events_path}, {name: @event.title, path: event_path(@event)}]
    
    # 閲覧数を記録（同じIPアドレスからは1日1回のみ）
    EventView.record_view!(@event, request.remote_ip)

    # イベントの最初の画像を取得（N+1対策済みのincludesを活用）
    @og_image = @event.images.attached? && @event.images.any? ?
                url_for(@event.images.first) :
                asset_url("marchelogo2.png")

    # OGPタグを設定
    set_meta_tags(
      title: @event.title,
      description: @event.description,
      og: {
        title: @event.title,
        description: @event.description,
        image: @og_image
      },
      twitter: {
        card: "summary_large_image",
        image: @og_image
      }
    )
  end

  def new
    set_prefectures
    @event = Event.new
  end

  def create
    set_prefectures
    # 日時フィールドを除外したパラメータでイベントを作成
    safe_params = event_params.except(:start_time_year, :start_time_month, :start_time_day, :start_time_hour, :start_time_minute, :end_time_year, :end_time_month, :end_time_day, :end_time_hour, :end_time_minute)
    @event = current_seller.events.build(safe_params)
    combine_datetime_parts(@event) # 開始日時と終了日時を結合

    # SolidQueueJobの使用箇所を確認
    if params[:solid_queue_job].present?
      solid_queue_job = SolidQueueJob.new(params[:solid_queue_job])
      # 修正前: solid_queue_job.arguments = JSON.parse(params[:arguments])
      solid_queue_job.arguments = params[:arguments] # JSON型カラムには直接代入可能
      solid_queue_job.save
    end

    if @event.save
      flash[:notice] = "\u30A4\u30D9\u30F3\u30C8\u304C\u4F5C\u6210\u3055\u308C\u307E\u3057\u305F"
      redirect_to event_path(@event)
    else
      flash[:alert] = @event.errors.full_messages.join(", ")
      render :new
    end
  end

  def edit
    set_prefectures
    redirect_to events_path, alert: "\u30ED\u30B0\u30A4\u30F3\u3057\u3066\u304F\u3060\u3055\u3044" unless @event.seller == current_seller
  end

  def update
    set_prefectures
    if @event.seller == current_seller
      begin
        combine_datetime_parts(@event) # 開始日時と終了日時を結合

        # トランザクション内で安全に画像を管理
        ActiveRecord::Base.transaction do
          # まず他のフィールドを更新（画像以外）
          safe_params = event_params.except(:images, :keep_images, :remove_images)
          raise ActiveRecord::Rollback unless @event.update!(safe_params)

          # 画像の削除処理：keep_imagesにないものを削除
          if @event.images.attached? && params.dig(:event, :keep_images).present?
            kept_signed_ids = params[:event][:keep_images]

            @event.images.each do |attachment|
              begin
                # チェックされていない（保持リストにない）画像を削除
                unless kept_signed_ids.include?(attachment.signed_id)
                  attachment.purge_later
                end
              rescue => e
                Rails.logger.error "画像削除エラー: #{e.message}"
                # 個別の画像削除エラーは無視して処理継続
              end
            end
          end
        end

        # 新しい画像の追加処理
        if params.dig(:event, :images).present?
          valid_images = params[:event][:images].reject(&:blank?)
          valid_images.each do |image|
            begin
              # 重複チェックしてから追加
              existing_filenames = @event.images.map { |img| img.blob&.filename&.to_s }.compact
              unless existing_filenames.include?(image.original_filename)
                @event.images.attach(image)
              end
            rescue => e
              Rails.logger.error "画像追加エラー: #{e.message}"
              # 個別の画像追加エラーは無視
            end
          end
        end

        flash[:notice] = "イベントが更新されました"
        redirect_to @event
      rescue => e
        Rails.logger.error "イベント更新エラー: #{e.message}"
        flash[:alert] = "更新中にエラーが発生しました。もう一度お試しください。"
        render :edit
      end
    else
      redirect_to events_path, alert: "ログインしてください"
    end
  end

  def destroy
    # @event は set_event で既に設定されているはず

    # 削除権限のチェック (重要: 誰でも削除できないようにする)
    unless current_seller == @event.seller || current_host == @event.host
      redirect_to root_path, alert: "\u30A4\u30D9\u30F3\u30C8\u3092\u524A\u9664\u3059\u308B\u6A29\u9650\u304C\u3042\u308A\u307E\u305B\u3093\u3002"
      return
    end

    if @event.destroy
      # 修正: 削除成功時のリダイレクト先とメッセージ
      flash[:notice] = "イベントを削除しました。" # 成功メッセージに変更
      if @event.seller.present?
        redirect_to seller_path(@event.seller) # セラーに紐づくイベントならセラーの詳細へ
      elsif @event.host.present?
        redirect_to public_host_profile_path(@event.host.slug || @event.host.id) # ホストに紐づくイベントならホストの詳細へ
      else
        redirect_to root_path, alert: "イベントを削除しました。" # どちらにも紐づかない場合
      end
    else
      flash[:alert] = "イベントの削除に失敗しました。" # 失敗メッセージ
      redirect_to event_path(@event) # 削除失敗時はイベント詳細ページへ
    end
  end

  private

  def combine_datetime_parts(event)
    if params[:event][:start_time_year].present? &&
       params[:event][:start_time_month].present? &&
       params[:event][:start_time_day].present? &&
       params[:event][:start_time_hour].present? &&
       params[:event][:start_time_minute].present?
      event.start_time = Time.zone.local(
        params[:event][:start_time_year].to_i,
        params[:event][:start_time_month].to_i,
        params[:event][:start_time_day].to_i,
        params[:event][:start_time_hour].to_i,
        params[:event][:start_time_minute].to_i
      )
    end

    if params[:event][:end_time_year].present? &&
       params[:event][:end_time_month].present? &&
       params[:event][:end_time_day].present? &&
       params[:event][:end_time_hour].present? &&
       params[:event][:end_time_minute].present?
       event.end_time = Time.zone.local(
        params[:event][:end_time_year].to_i,
        params[:event][:end_time_month].to_i,
        params[:event][:end_time_day].to_i,
        params[:event][:end_time_hour].to_i,
        params[:event][:end_time_minute].to_i
      )
    end
  end

  def event_params
    params.require(:event).permit(
      :title, :description, :venue, :address, :latitude, :longitude,
      :capacity, :is_online, :online_url, :is_free, :price, :organizer,
      :contact_info, :business_hours_days, :website, :status, :video, :category_id,
      :start_time_year, :start_time_month, :start_time_day, :start_time_hour, :start_time_minute,
      :end_time_year, :end_time_month, :end_time_day, :end_time_hour, :end_time_minute,
      images: [], remove_images: [], keep_images: []
    )
  end

  def set_event
    @event = Event.includes(:host, :seller, images_attachments: :blob).find(params[:id])
  end



  def set_prefectures
    @prefectures = %w[
      北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
      茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
      新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県
      静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県
      奈良県 和歌山県 鳥取県 島根県 岡山県 広島県 山口県
      徳島県 香川県 愛媛県 高知県 福岡県 佐賀県 長崎県
      熊本県 大分県 宮崎県 鹿児島県 沖縄県
    ]
  end
end
