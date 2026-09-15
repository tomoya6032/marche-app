module Admin
  class AdminHostsController < ApplicationController
     # Host の CRUD 操作にのみ set_host を適用
  before_action :set_host, only: [:show, :edit, :update, :destroy, :toggle_display_in_list]

    def index
      @hosts = Host.all # ホストの一覧表示 (必要であれば)
    end

    def show
      @host = Host.find(params[:id])
      @admin_comments = @host.comments.where(commenter_type: 'Administrator').order(created_at: :desc)
      
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

    def toggle_editable
      @host = Host.find(params[:id])
      if @host.update(editable: params[:editable] == "1") # チェックボックスの値を確認
        redirect_to admin_users_path, notice: "編集可能状態を更新しました。"
      else
        redirect_to admin_users_path, alert: "編集可能状態の更新に失敗しました。"
      end
    end

    def toggle_display_in_list
      if @host.update(display_in_list: !@host.display_in_list)
        redirect_to admin_users_path, notice: "一覧表示状態を更新しました。"
      else
        redirect_to admin_users_path, alert: "一覧表示状態の更新に失敗しました。"
      end
    end

    private

    

    def set_host
      @host = Host.find_by(id: params[:id]) || Host.find_by!(slug: params[:id])
    rescue ActiveRecord::RecordNotFound
      # ★★★ ここでエラーメッセージをより具体的にするとデバッグに役立ちます ★★★
      redirect_to admin_hosts_path, alert: "指定されたホストが見つかりませんでした。無効な識別子: #{params[:id]}"
    end

    def host_params
      params.require(:host).permit(:name, :email, :description, :address, :phone_number, :website, :video, :business_hours_days, :business_hours_start, :business_hours_end, :past_exhibitions_names, :past_exhibitions_dates, sns_accounts_types: [], sns_accounts_urls: [], images: [], admin_comment: params[:admin_comment])
    end
  end
end