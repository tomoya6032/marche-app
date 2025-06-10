class HostsController < ApplicationController
  before_action :authenticate_host!, only: [ :edit, :update, :destroy, :new_event, :create_event]
  before_action :set_host, only: [ :show, :edit, :update, :destroy, :new_event, :create_event]
  before_action :set_event, only: [:edit_event, :update_event, :destroy_event]

  def index
       @host = current_host
       @comments = @host.comments.order(created_at: :desc) # 管理者からのコメントを取得
      #  @events = @host.events.order(created_at: :desc) # ホストが出店したイベントを取得
       @events = @host.events if @host # ホストに紐づくイベントを取得する場合
  end

  def show
    @events = @host.events.order(start_time: :desc).limit(5) # 開催日が近い順に直近5件を取得
    @topics_text = @host.topics # トピックスのテキストを取得
    @news_text = @host.news # 新着ニュースのテキストを取得
    @events = @host.events
    @goods_introduction_text = @host.goods_introduction # 商品紹介のテキストを取得
    @events = @host.events.order(start_time: :asc) # ホストに関連するイベントを取得し、開催日順に並べる
    @events = @host.events.order(created_at: :desc).limit(10) # 最新の10件を取得
  end

  def edit
    
  end
  def update
    
    # トップ画像の削除
    if params[:remove_top_image] == '1'
      @host.top_image.purge
    end

    # 削除する画像の処理 (host_params の更新とは独立して実行)
    if params[:host][:keep_images].present?
      keep_image_ids = params[:host][:keep_images].map { |signed_id| ActiveStorage::Blob.find_signed(signed_id).id }
      @host.images.each do |image|
        image.purge unless keep_image_ids.include?(image.blob_id)
      end
    else
      # keep_images が送信されない場合は、既存の画像を全て削除する
      @host.images.purge
    end

    if @host.update(host_params.except(:images))
       # 新しい画像の添付処理
      if params[:host][:images].present?
        params[:host][:images].each do |image|
          @host.images.attach(image)
        end
      end

      redirect_to host_path(@host), notice: 'プロフィールを更新しました。'
    else
# プロフィールの基本情報更新に失敗した場合の処理
      render :edit
    end
  end

  def destroy
    @host.destroy
    redirect_to root_path, notice: 'アカウントを削除しました。'
  end

  # イベントの新規作成
  def new_event
    @event = @host.events.build # @host を基にイベントを初期化
  end

  def create_event
    @event = @host.events.build(event_params)
    if @event.save
      redirect_to hosts_path, notice: 'イベントが作成されました。'
    else
      render :new_event
    end
  end

  # イベントの編集
  def edit_event
  end

  def update_event
    if @event.update(event_params)
      redirect_to hosts_path, notice: 'イベントが更新されました。'
    else
      render :edit_event
    end
  end

  # イベントの削除
  def destroy_event
    @event.destroy
    redirect_to hosts_path, notice: 'イベントが削除されました。'
  end

  private

  def set_host
    @host = Host.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to hosts_path, alert: 'ホストが見つかりませんでした。'
  end

  def set_event
    @event = @host.events.find(params[:id])
  end

  # def host_params
  #   params.require(:host).permit(:name, :email, :description, :venue, :address, :phone_number, :website, :top_image, :news, :topics, :goods_introduction, images: [])
  # end

  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :venue, :address, :latitude, :longitude, :capacity, :is_online, :online_url, :is_free, :price, :organizer, :contact_info, :website, :status, :image, :video, :category_id)
  end


  def host_params
    params.require(:host).permit(
      :name, :email, :description, :address, :phone_number, :website, :top_image, :news, :topics, :business_hours_days, :business_hours_start, :business_hours_end,
      :goods_introduction_1, :goods_image_1,
      :goods_introduction_2, :goods_image_2,
      :goods_introduction_3, :goods_image_3,
      :goods_introduction_4, :goods_image_4,
      :contact_link, # 新しいカラムを許可
      images: [] # 複数画像添付用
    )
  end
end      