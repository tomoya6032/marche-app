class EventsController < ApplicationController
  def index
    @events = Event.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
  end
end
