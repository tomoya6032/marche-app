class EventLike < ApplicationRecord
  belongs_to :event, counter_cache: :likes_count
  belongs_to :seller, optional: true
  belongs_to :host, optional: true

  validates :event_id, presence: true

  # A visitor can be identified by visitor_token when not signed in.
  # Prevent duplicate likes from same actor
  def self.find_by_actor(event:, seller: nil, host: nil, visitor_token: nil)
    if seller
      find_by(event: event, seller_id: seller.id)
    elsif host
      find_by(event: event, host_id: host.id)
    else
      find_by(event: event, visitor_token: visitor_token)
    end
  end
end
