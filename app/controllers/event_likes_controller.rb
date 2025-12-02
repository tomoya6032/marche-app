class EventLikesController < ApplicationController
  before_action :set_event

  def create
    visitor_token = session[:visitor_token] ||= SecureRandom.uuid

    existing = EventLike.find_by_actor(event: @event, seller: current_seller, host: current_host, visitor_token: visitor_token)
    if existing
      render json: { liked: true, likes_count: @event.likes_count, like_id: existing.id }
      return
    end

    like = @event.event_likes.new
    if seller_signed_in?
      like.seller = current_seller
    elsif host_signed_in?
      like.host = current_host
    else
      like.visitor_token = visitor_token
    end

    if like.save
      render json: { liked: true, likes_count: @event.reload.likes_count, like_id: like.id }
    else
      render json: { error: 'could not like' }, status: :unprocessable_entity
    end
  end

  def destroy
    like = @event.event_likes.find_by(id: params[:id])
    unless like && allowed_to_modify?(like)
      render json: { error: 'not found or unauthorized' }, status: :not_found
      return
    end

    like.destroy
    render json: { liked: false, likes_count: @event.reload.likes_count }
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def allowed_to_modify?(like)
    return true if seller_signed_in? && like.seller_id == current_seller&.id
    return true if host_signed_in? && like.host_id == current_host&.id
    return true if session[:visitor_token].present? && like.visitor_token == session[:visitor_token]
    false
  end
end
