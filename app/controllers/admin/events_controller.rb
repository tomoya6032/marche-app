# app/controllers/admin/events_controller.rb
module Admin
  class EventsController < ApplicationController
    before_action :set_event, only: [ :show, :edit, :update, :destroy ]

    def index
      @events = Event.all.page(params[:page]).per(10) # 全イベントをページネーション

      # 人気イベント統計も表示
      @popular_events_this_week = Event.popular_this_week(5)
      @total_views_this_week = EventView.where(viewed_at: 1.week.ago..Time.current).count
      @total_views_today = EventView.where(viewed_at: Date.current.beginning_of_day..Date.current.end_of_day).count
    end

    def show
    end

    def new
      @event = Event.new
    end

    def create
      @event = Event.new(event_params)
      if @event.save
        redirect_to admin_events_path, notice: "イベントを作成しました。"
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @event.update(event_params)
        redirect_to admin_events_path, notice: "イベントを更新しました。"
      else
        render :edit
      end
    end

    def destroy
      @event.destroy
      redirect_to admin_events_path, notice: "イベントを削除しました。"
    end

    # ★★★ 注目イベントを更新するアクションの修正 ★★★
    # アクション名を 'featured' から 'update_event_features' に変更し、
    # params[:events] の構造に対応します。
    def update_event_features # <-- ここを修正
      # params[:events] は { "イベントID1" => { "is_featured" => "true/false", "id" => "イベントID1" }, ... } の形式
      if params[:events].present?
        params[:events].each do |event_id, attributes| # id を event_id に変更して明確化
          event = Event.find_by(id: event_id)
          if event
            # チェックボックスの値 "true" / "false" をブーリアンに変換
            new_is_featured = (attributes[:is_featured] == "true")
            # 変更がある場合のみ更新してDBアクセスを減らす
            event.update(is_featured: new_is_featured) unless event.is_featured == new_is_featured
          end
        end
        flash[:notice] = "注目イベントの設定を更新しました。"
      else
        flash[:alert] = "更新するイベントが選択されていません。"
      end

      # 管理画面ダッシュボードにリダイレクト
      redirect_to admin_users_path
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      # `update_event_features` アクションでは `params[:events]` を直接処理するため、
      # この `event_params` は使われません。
      # ただし、`create` や `update` アクションで `is_featured` を扱いたい場合は残します。
      params.require(:event).permit(:title, :description, :start_time, :venue, :is_featured)
    end
  end
end
