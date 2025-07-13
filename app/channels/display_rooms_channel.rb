class DisplayRoomsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "display_rooms_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
