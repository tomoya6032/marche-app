class HostsController < ApplicationController
  before_action :authenticate_host!
  before_action :set_host, only: [:show, :edit, :update, :destroy, :new_event, :create_event]
  before_action :set_event, only: [:edit_event, :update_event, :destroy_event]

  def index
     @host = current_host
     @comments = @host.comments.order(created_at: :desc) # 管理者からのコメントを取得
      @events = @host.events.order(created_at: :desc) # ホストが出店したイベントを取得
     @events = @host.events if @host # ホストに紐づくイベントを取得する場合
  end

  def show
  end

  def edit
  
  end
  def update
    if @host.update(host_params)
      # プロフィールの基本情報を更新成功した場合の処理
      if params[:host][:remove_top_image] == '1'
        @host.top_image.purge
      end

      if params[:host][:remove_images].present?
        params[:host][:remove_images].each do |image_id|
          if image = @host.images.find_by(id: image_id)
            image.purge
          end
        end
      end

      # 新しい画像が送信されていれば添付する
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
    @host = current_host
  end

  def set_event
    @event = @host.events.find(params[:id])
  end

  def host_params
    params.require(:host).permit(:name, :email, :description, :address, :phone_number, :website, :top_image, images: [])
  end

  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :venue, :address, :latitude, :longitude, :capacity, :is_online, :online_url, :is_free, :price, :organizer, :contact_info, :website, :status, :image, :video, :category_id)
  end


end