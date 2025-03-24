class EventsController < ApplicationController
  def index
    
    # @events = Event.all

    @events = Event.order(created_at: :desc).page(params[:page]).per(10)
    
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end
  
  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:notice] = 'イベントが作成されました'
      redirect_to event_path (@event)
    else
      puts @event.errors.full_messages # エラーメッセージをコンソールに出力
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update(event_params)
      if params[:event][:images].present?
        @event.images.purge # 既存の画像をクリア
        @event.images.attach(params[:event][:images])
      end
      flash[:notice] = 'イベントが更新されました'
      redirect_to @event
    else
      @event.assign_attributes(event_params)
      puts @event.errors.full_messages # エラーメッセージをコンソールに出力
      render :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy!
    redirect_to events_path(@event), notice: '削除に成功しました'
    # event = current_user.events.find(params[:id])
    # event.destroy!
    # redirect_to events_path(@event), notice: '削除に成功しました'

  end
   
  private
  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :venue, :address, :latitude, :longitude, :capacity, :is_online, :online_url, :is_free, :price, :organizer, :contact_info, :website, :status, :video, :category_id, images: [])
    # :facility_id を入れない形で進めていく
  end

  # def set_event
  #   @event = Event.find(params[:id])
  # end



end

