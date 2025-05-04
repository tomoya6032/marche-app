module Admin
  class AdminHostsController < ApplicationController
    before_action :set_host, only: [ :edit, :update, :destroy ] # update と destroy でも使用するため追加

    def index
      @hosts = Host.all # ホストの一覧表示 (必要であれば)
    end

    def edit
@admin_comments = @host.comments.where(admin_id: current_administrator.id).order(created_at: :desc)
      # before_action で @host はセット済み
    end

    def update
      if @host.update(host_params)
        redirect_to admin_hosts_path, notice: 'ホスト情報を更新しました。'
      else
        render :edit
      end
    end

    def destroy
      @host.destroy
      redirect_to admin_hosts_path, notice: 'ホストを削除しました。'
    end

    private

    def set_host
      @host = Host.find(params[:id])
    end

    def host_params
      params.require(:host).permit(:name, :email, :description, :address, :phone_number, :website, :video, :business_hours_days, :business_hours_start, :business_hours_end, :past_exhibitions_names, :past_exhibitions_dates, sns_accounts_types: [], sns_accounts_urls: [], images: [], admin_comment: params[:admin_comment])
    end
  end
end