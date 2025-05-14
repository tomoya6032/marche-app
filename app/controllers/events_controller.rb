class EventsController < ApplicationController
  before_action :authenticate_seller!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]
  before_action :set_prefectures, only: [ :index, :new, :edit, :create ]

  def index
    @events = if params[:filter] == 'recent'
      Event.order(:start_time) # 開催日の近い順に取得
    else
      Event.all # 通常のイベント一覧を取得 (並び順はデフォルト)
    end

    if params[:prefecture].present?
      @events = Event.where(venue: params[:prefecture])
    end

    if @events.empty?
      @message = "該当するイベントは見つかりませんでした。"
    end

    # 並び替えパラメータに基づいて並び替え
    case params[:sort]
    when "start_time_asc"
      @events = @events.order(:start_time) # 開始日時の昇順
    when "start_time_desc"
      @events = @events.order(start_time: :desc) # 開始日時の降順
    else
      @events = @events.order(created_at: :desc) # デフォルトは作成日時の降順
    end

    @events = @events.page(params[:page]).per(10)

    puts "params[:prefecture]: #{params[:prefecture]}"
    puts "params[:sort]: #{params[:sort]}"
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
    @event = Event.find(params[:id])
    if @event.destroy
      flash[:notice] = 'イベントを削除しました。'
      redirect_to events_path
    else
      flash[:alert] = 'イベントの削除に失敗しました。'
      redirect_to event_path(@event)
    end
  end

  private

  def combine_datetime_parts(event)
    if params[:event][:start_time_year].present? &&
       params[:event][:start_time_month].present? &&
       params[:event][:start_time_day].present? &&
       params[:event][:start_time_hour].present? &&
       params[:event][:start_time_minute].present?
      event.start_time = DateTime.new(
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
      event.end_time = DateTime.new(
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
      :contact_info, :website, :status, :video, :category_id, images: [], remove_images: []
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
