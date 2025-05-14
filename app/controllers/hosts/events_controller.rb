module Hosts
  class EventsController < ApplicationController
    before_action :authenticate_host! # ホストとしてログインしている必要あり
    before_action :set_host
    before_action :set_event, only: [:show, :edit, :update, :destroy]
    before_action :set_prefectures, only: [:new, :edit]

    def index
      @events = @host.events.all # ホストに紐づくイベントをすべて取得
    end

    def show
      # @event は set_event で設定される
    end

    def new
      set_prefectures
      @event = @host.events.build
    end

    def create
      @event = @host.events.build(event_params)
      if @event.save
        redirect_to host_events_path(@host), notice: 'イベントを作成しました。'
      else
        render :new, alert: 'イベントの作成に失敗しました。'
      end
    end

    def edit
      set_prefectures
      # イベント編集フォームを表示
    end

    def update
      set_prefectures
      combine_datetime_parts(@event)

      # 削除対象の画像を処理
      if params[:event][:keep_images].present?
        keep_image_ids = params[:event][:keep_images].map { |signed_id| ActiveStorage::Blob.find_signed(signed_id).id }
        @event.images.each do |image|
          image.purge unless keep_image_ids.include?(image.blob_id)
        end
      else
        # keep_images が送信されない場合は、既存の画像を全て削除する
        @event.images.purge
      end

      if @event.update(event_params.except(:images))
      # 新しい画像を追加
      if params[:event][:images].present?
        params[:event][:images].each do |image|
          @event.images.attach(image)
        end
      end

      # if @event.update(event_params.except(:keep_images)) # keep_images を除外して更新
        redirect_to host_event_path(@host, @event), notice: 'イベントが更新されました。'
      else
        flash[:alert] = 'イベントの更新に失敗しました。'
        render :edit
      end
    end

    def destroy
      @event.destroy
      redirect_to host_path(@host), notice: 'イベントが削除されました。'
    end

    private

    def set_host
      @host = Host.find(params[:host_id])
      redirect_to hosts_path, alert: 'ホストが見つかりません。' if @host.nil?
    end

    def set_event
      @event = @host.events.find_by(id: params[:id])
      redirect_to host_events_path(@host), alert: 'イベントが見つかりません。' if @event.nil?
    end

    def event_params
      params.require(:event).permit(
        :title, :description, :start_time, :end_time, :venue, :address, :latitude, :longitude,
        :capacity, :is_online, :online_url, :is_free, :price, :organizer, :contact_info, :website,
        :status, :video, :category_id, images: []
      )
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
  end
end
