class SellersController < ApplicationController
  before_action :authenticate_seller!, only: [ :edit, :update, :destroy ]
  before_action :set_seller, only: [:show, :edit, :update, :destroy ]
  

  def index
    # セラーのマイページの処理
    @seller = current_seller
    @comments = @seller.comments.order(created_at: :desc) # 管理者からのコメントを取得
    @events = @seller.events.order(created_at: :desc) # ホストが出店したイベントを取得
    @events = @seller.events if @seller # ホストに紐づくイベントを取得する場合
  
  end

  def show
    Rails.logger.info "@seller in show: #{@seller.inspect}"
  end

  def edit
  end

  def update
    if @seller.update(seller_params)
      if params[:seller][:images].present?
        @seller.image.attach(params[:seller][:image])
      end
      redirect_to sellers_path, notice: "\u30D7\u30ED\u30D5\u30A3\u30FC\u30EB\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F\u3002"
    else
      render :edit
    end
  end

  def destroy
  end



  def set_seller
    @seller = current_seller
  end

  def set_seller
    @seller = Seller.find_by(id: params[:id])
    unless @seller
      flash[:alert] = "セラーが見つかりませんでした。"
      redirect_to sellers_path
    end
  end

  # def set_event
  #   @event = @seller.events.find(params[:id])
  # end

  def seller_params
    params.require(:seller).permit(:name, :description, :address, :phone_number, :website, :video, :business_hours_days, :business_hours_start, :business_hours_end,
    :past_exhibitions_names, :past_exhibitions_dates, sns_accounts_types: [], sns_accounts_urls: [], images: [])
  end

  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :venue, :address, :latitude, :longitude, :capacity, :is_online, :online_url, :is_free, :price, :organizer, :contact_info, :website, :status, :image, :video, :category_id)
  end
end
