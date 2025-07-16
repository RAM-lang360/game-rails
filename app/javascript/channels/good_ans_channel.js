import consumer from "channels/consumer"
document.addEventListener('turbo:load', () => {
  console.log("turbo:load イベントが発火しました。");
  const roomId = document.querySelector('[data-good-ans-id]')?.dataset.goodAnsId;
  if (roomId) {
  consumer.subscriptions.create("GoodAnsChannel", {
    connected() {
      console.log("GoodAnsChannelに接続しました");
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      // Called when there's incoming data on the websocket for this channel
      console.log("GoodAnsChannelからデータを受信しました:", data);
    }
  });
  }
});