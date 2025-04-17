class SellersController < ApplicationController
  before_action :authenticate_seller!
  before_action :set_seller, only: [:show, :edit, :update, ]

  def index
    # セラーのマイページの処理
    @seller = current_seller
  end

  def show
    
  end

  def edit
  end

  def update
    if @seller.update(seller_params)
      if params[:seller][:images].present?
        @seller.image.attach(params[:seller][:image])
      end
      redirect_to sellers_path, notice: 'プロフィールを更新しました。'
    else
      render :edit
    end
  end

  def destroy
   

  end



  def set_seller
    @seller = current_seller
  end

  def seller_params
    params.require(:seller).permit(:name, :description, :address, :phone_number, :website, :video, :business_hours_days, :business_hours_start, :business_hours_end,
    :past_exhibitions_names, :past_exhibitions_dates, sns_accounts_types: [], sns_accounts_urls: [], images: [])
  end

end
