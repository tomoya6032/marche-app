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
      redirect_to event_path (@event), notice: 'イベントが作成されました。'
    else
      puts @event.errors.full_messages # エラーメッセージをコンソールに出力
      render :new
    end
  end
   
  private
  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :venue, :address, :latitude, :longitude, :capacity, :is_online, :online_url, :is_free, :price, :organizer, :contact_info, :website, :status, :image, :video, :category_id, )
    # :facility_id を入れない形で進めていく
  end

  # def set_event
  #   @event = Event.find(params[:id])
  # end



end

