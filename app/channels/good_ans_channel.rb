class GoodAnsChannel < ApplicationCable::Channel
  def subscribed
    room_id = params[:room_id]
    stream_from "good_ans_channel_#{room_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
