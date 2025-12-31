class SellersController < ApplicationController
  before_action :authenticate_seller!, only: [:edit, :update, :destroy]
  before_action :set_seller, only: [:show, :edit, :update, :destroy]

  def index
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "セラー一覧", path: sellers_path}]
    # セラーのマイページの処理
    @seller = current_seller
    @comments = @seller.comments.order(created_at: :desc) # 管理者からのコメントを取得
    @events = @seller.events.order(created_at: :desc) # ホストが出店したイベントを取得
    @events = @seller.events if @seller # ホストに紐づくイベントを取得する場合
  end

  def show
    @breadcrumbs = [{name: "ホーム", path: root_path}, {name: "セラー一覧", path: sellers_path}, {name: @seller.name, path: seller_path(@seller)}]
    Rails.logger.info "@seller in show: #{@seller.inspect}"
  end

  def edit
  end

  def update
    # 削除対象の画像を処理 (seller_params の更新とは独立して実行)
    if params[:seller][:keep_images].present?
      keep_image_ids = params[:seller][:keep_images].map { |signed_id| ActiveStorage::Blob.find_signed(signed_id).id }
      @seller.images.each do |image|
        image.purge unless keep_image_ids.include?(image.blob_id)
      end
    else
      # keep_images が送信されない場合は、既存の画像を全て削除する
      @seller.images.purge
    end

    if @seller.update(seller_params.except(:images)) # images パラメータを除外して更新
      # 新しい画像を添付
      if params[:seller][:images].present?
        params[:seller][:images].each do |image|
          @seller.images.attach(image)
        end
      end

      redirect_to seller_path(@seller), notice: 'プロフィールを更新しました。'
    else
      flash[:alert] = 'セラー情報の更新に失敗しました。'
      render :index
    end
  end

  def destroy
  end


  private

  def set_seller
    @seller = Seller.find(params[:id])
  end

  def seller_params
    params.require(:seller).permit(:name, :description, :address, :phone_number, :email, :website, :business_hours_days, :business_hours_start, :business_hours_end, images: [])
  end
end
