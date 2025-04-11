class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update]
  before_action :authenticate_seller!, only: [:edit, :update, :destroy]

  def index
    set_prefectures # 共通化

    if params[:prefecture].present? # 都道府県が選択されている場合
      @events = Event.where(venue: params[:prefecture])
    else
      @events = Event.all
    end

    if @events.empty?
      @message = "該当するイベントは見つかりませんでした。"
    end

    @events = @events.order(created_at: :desc).page(params[:page]).per(10)

    puts "params[:prefecture]: #{params[:prefecture]}"
  end

  def show
    # @event = Event.find(params[:id]) # set_eventで読み込んでいるので、表示させる必要がない
  end

  def new
    set_prefectures # 共通化
    @event = Event.new
    
    
  end
  
  def create
    @event = Event.new(event_params)
    set_prefectures # 共通化
    if @event.save
      flash[:notice] = 'イベントが作成されました'
      redirect_to event_path (@event)
    else
      puts @event.errors.full_messages # エラーメッセージをコンソールに出力
      render :new
    end
  end

  def edit
    set_prefectures # 共通化
    # @event = Event.find(params[:id]) # set_eventで読み込んでいるので、表示させる必要がない
  end

  def update
    set_prefectures # 共通化
    # @event = Event.find(params[:id]) # set_eventで読み込んでいるので、表示させる必要がない
    if @event.update(event_params)
      if params[:event][:images].present?
        @event.images.purge # 既存の画像をクリア
        @event.images.attach(params[:event][:images])
      end
      flash[:notice] = 'イベントが更新されました'
      redirect_to @event
    else
      puts @event.errors.full_messages # エラーメッセージをコンソールに出力
      render :edit
    end

   
  end

  def destroy
    event = Event.find(params[:id]) 
    event.destroy!
    redirect_to events_path(@event), notice: '削除に成功しました'
    # event = current_user.events.find(params[:id])
    # event.destroy!
    # redirect_to events_path(@event), notice: '削除に成功しました'

  end
   
  private
  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :venue, :address, :latitude, :longitude, :capacity, :is_online, :online_url, :is_free, :price, :organizer, :contact_info, :website, :status, :video, :category_id, images: [])
    # :facility_id を入れない形で進めていく
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def set_prefectures # 共通化
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

