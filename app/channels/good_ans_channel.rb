class GoodAnsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "good_ans_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
