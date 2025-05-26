module Admin
  class AdminSellersController < ApplicationController
    before_action :set_seller, only: [ :index, :edit, :update, :destroy, :toggle_editable]

    def index
      @sellers = Seller.all
    end

    def show
      @seller = Seller.find(params[:id]) # @user インスタンス変数にセラー情報を代入
      @admin_comments = @seller.comments.where(commenter_type: 'Administrator').order(created_at: :desc)
     
    end

    def edit
      @admin_comments = @seller.comments.where(admin_id: current_administrator.id).order(created_at: :desc)
    end

    def update
      if @seller.update(seller_params)
        redirect_to admin_sellers_path, notice: "\u30BB\u30E9\u30FC\u60C5\u5831\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F\u3002"
      else
        render :edit
      end
    end

    def destroy
      @seller.destroy
      redirect_to admin_sellers_path, notice: "\u30BB\u30E9\u30FC\u3092\u524A\u9664\u3057\u307E\u3057\u305F\u3002"
    end

    def toggle_editable
      @seller = Seller.find(params[:id])
      if @seller.update(editable: params[:editable] == "1") # チェックボックスの値を確認
        redirect_to admin_users_path, notice: "編集可能状態を更新しました。"
      else
        redirect_to admin_users_path, alert: "編集可能状態の更新に失敗しました。"
      end
    end

    

    private

   

    def set_seller
      @seller = Seller.find(params[:id])
    end

    def seller_params
      params.require(:seller).permit(:name, :email, :description, :address, :phone_number, :website, :video, :business_hours_days, :business_hours_start, :business_hours_end, :past_exhibitions_names, :past_exhibitions_dates, sns_accounts_types: [], sns_accounts_urls: [], images: [], admin_comment: params[:admin_comment])
    end
  end
end
