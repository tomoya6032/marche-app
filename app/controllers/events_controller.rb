class EventsController < ApplicationController
  before_action :authenticate_seller!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]
  before_action :set_prefectures, only: [ :index, :new, :edit, :create ]

  def index
    # 基本のイベント取得
    
    @events = Event.includes(:host, :seller, images_attachments: :blob).order(created_at: :desc).limit(10)
  # フィルタリング: 開催日の近い順
  if params[:filter] == "recent"
    @events = @events.order(:start_time)
  end

  # フィルタリング: 都道府県
  if params[:prefecture].present?
    @events = @events.where(venue: params[:prefecture])
  end

  # 並び替え処理
  case params[:sort]
  when "start_time_asc"
    @events = @events.order(:start_time) # 開始日時の昇順
  when "start_time_desc"
    @events = @events.order(start_time: :desc) # 開始日時の降順
  else
    @events = @events.order(created_at: :desc) # デフォルトは作成日時の降順
  end

    @events = @events.page(params[:page]).per(10)

    # puts "params[:prefecture]: #{params[:prefecture]}"
    # puts "params[:sort]: #{params[:sort]}"
  end

  def show
    # @event = Event.find(params[:id]) # set_eventで読み込んでいるので、表示させる必要がない
  end

  def new
    set_prefectures
    @event = Event.new
  end

  def create
    set_prefectures
    @event = current_seller.events.build(event_params)
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
      combine_datetime_parts(@event) # 開始日時と終了日時を結合

      # 削除対象の画像を処理
      if params[:event][:remove_images].present?
        params[:event][:remove_images].each do |signed_id|
          image = ActiveStorage::Blob.find_signed(signed_id)
          @event.images.find_by(blob_id: image.id)&.purge if image
        end
      end

      if @event.update(event_params)
        # 既存の画像を保持
        if params[:event][:keep_images].present?
          params[:event][:keep_images].each do |signed_id|
            image = ActiveStorage::Blob.find_signed(signed_id)
            unless @event.images.map(&:blob_id).include?(image.id) # 重複を防ぐ
              @event.images.attach(image) if image
            end
          end
        end

        # 新しい画像がアップロードされた場合のみ追加
        if params[:event][:images].present?
          valid_images = params[:event][:images].reject(&:blank?) # 空のファイルフィールドを除外
          valid_images.each do |image|
            unless @event.images.map(&:filename).include?(image.original_filename) # 重複を防ぐ
              @event.images.attach(image)
            end
          end
        end

        flash[:notice] = "イベントが更新されました"
        redirect_to @event
      else
        flash[:alert] = @event.errors.full_messages.join(", ")
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
      :contact_info, :business_hours_days, :website, :status, :video, :category_id, images: [], remove_images: []
    )
  end

  def set_event
    @event = Event.find(params[:id])
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
