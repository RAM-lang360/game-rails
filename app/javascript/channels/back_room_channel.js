import consumer from "channels/consumer"

document.addEventListener('turbo:load', () => {
  const roomId = document.querySelector('[data-good-ans-id]')?.dataset.goodAnsId;
  if (roomId) {
    console.log(`ルーム${roomId}のバックルームチャンネルに接続中...`);

    consumer.subscriptions.create({ channel: "BackRoomChannel", room_id: roomId }, {
      connected() {
        console.log(`ルーム${roomId}のバックルームチャンネルに接続しました`);
      },

      disconnected() {
        console.log(`ルーム${roomId}のバックルームチャンネルから切断されました`);
      },

      received(data) {
        console.log("バックルーム指示を受信:", data);

        if (data.action === "redirect") {
          console.log(`${data.url}にリダイレクト中...`);
          window.location.href = data.url;
        }
      }
    });
  }
});



