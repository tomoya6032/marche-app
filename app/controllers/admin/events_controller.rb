module Admin
  class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]

    def index
      @events = Event.all
      @recent_events = Event.order(created_at: :desc).page(params[:page]).per(10)
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

    # 注目イベントを更新するアクション
    def featured
      Event.update_all(is_featured: false) # すべてのイベントの注目フラグをリセット

      if params[:featured_event_ids].present?
        Event.where(id: params[:featured_event_ids]).update_all(is_featured: true)
        flash[:notice] = "注目イベントを更新しました。"
      else
        flash[:alert] = "注目イベントが選択されていません。"
      end

      # 管理画面ダッシュボードにリダイレクト
      redirect_to admin_users_path
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :description, :start_time, :venue, :is_featured)
    end
  end
end