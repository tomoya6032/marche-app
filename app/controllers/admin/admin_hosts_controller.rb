module Admin
  class AdminHostsController < ApplicationController
     # Host の CRUD 操作にのみ set_host を適用
     before_action :set_host, only: [:show, :edit, :update, :destroy]

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

    private

    

    def set_host
      # ここで params[:id] が数値（通常のID）でない場合や、
      # 'events' や 'update_event_features' のような文字列であれば、
      # slug 検索を行わないように分岐できます。
      # しかし、これは本質的なルーティングの解決にはなりません。
      # 通常は params[:id] が Host の slug になる想定です。
  
      # 例えば、特定の文字列が来た場合にスキップする（応急処置）
      if ['events', 'update_event_features'].include?(params[:id])
        # このケースでは set_host を中断し、ルーティングエラーを発生させるか、
        # あるいは他の方法で処理すべきだが、現状の Rails のルーティング誤解釈では難しい
        # エラーメッセージを変えることくらいしかできない
        raise ActiveRecord::RecordNotFound, "Invalid host identifier provided: #{params[:id]}"
      end
  
      @host = Host.find_by!(slug: params[:id]) # `id` パラメータを `slug` として検索
    rescue ActiveRecord::RecordNotFound
      # ★★★ ここでエラーメッセージをより具体的にするとデバッグに役立ちます ★★★
      redirect_to admin_hosts_path, alert: "指定されたホストが見つかりませんでした。無効な識別子: #{params[:id]}"
    end

    def host_params
      params.require(:host).permit(:name, :email, :description, :address, :phone_number, :website, :video, :business_hours_days, :business_hours_start, :business_hours_end, :past_exhibitions_names, :past_exhibitions_dates, sns_accounts_types: [], sns_accounts_urls: [], images: [], admin_comment: params[:admin_comment])
    end
  end
end