import consumer from "channels/consumer"

document.addEventListener('turbo:load', () => {
  const roomId = document.querySelector('[data-room-id]')?.dataset.roomId;
  
  if (roomId) {
    console.log(`ルーム${roomId}のナビゲーションチャンネルに接続中...`);
    
    consumer.subscriptions.create({ channel: "NavigationChannel", room_id: roomId }, {
      connected() {
        console.log(`ルーム${roomId}のナビゲーションチャンネルに接続しました`);
      },

      disconnected() {
        console.log(`ルーム${roomId}のナビゲーションチャンネルから切断されました`);
      },

      received(data) {
        console.log("ナビゲーション指示を受信:", data);
        
        if (data.action === "redirect") {
          console.log(`${data.url}にリダイレクト中...`);
          window.location.href = data.url;
        }
      }
    });
  }
});