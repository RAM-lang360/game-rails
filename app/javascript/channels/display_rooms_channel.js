// app/javascript/channels/display_rooms_channel.js
import consumer from "channels/consumer"

console.log("display_rooms_channel.js がロードされました。");

document.addEventListener('turbo:load', () => {
  console.log("turbo:load イベントが発火しました。");

  const lobbyRoomsElement = document.getElementById('lobby-rooms');
  console.log("lobby-rooms要素が見つかる:", !!lobbyRoomsElement);
  
  if (lobbyRoomsElement) {
    console.log("DisplayRoomsChannelを購読開始...");
    
    consumer.subscriptions.create("DisplayRoomsChannel", {
      connected() {
        console.log("コネクトしたよ");
      },

      disconnected() {
        console.log("切れたよ");
      },

      received(data) {
        console.log("Received data:", data);
        
        if (data.action === "create") {
          this.handleRoomCreation(data);
        } else if (data.action === "delete") {
          this.handleRoomDeletion(data);
        }else {
          console.warn("不明なアクション:", data.action);
        }
      },

      handleRoomCreation(data) {
        const roomsList = document.querySelector('.rooms-list');
        console.log("rooms-list要素:", roomsList);
        
        if (roomsList) {
          // 「現在、ルームはありません。」メッセージを非表示
          const noRoomsMessage = document.querySelector('.no-rooms');
          if (noRoomsMessage) {
            noRoomsMessage.style.display = 'none';
          }
          
          // 新しいルームアイテムを追加
          const roomItem = document.createElement('div');
          roomItem.className = 'room-item';
          roomItem.id = `room-${data.room_id}`;
          roomItem.innerHTML = `
            <div class="room-card">
              <h3 class="room-name">${data.room_name}</h3>
              <p class="room-host">ホスト: ${data.host_name}</p>
              <p class="room-created-at">作成日時: ${data.created_at}</p>
            </div>
          `;
          roomsList.appendChild(roomItem);
          
          console.log("新しいルームアイテムを追加しました:", data.room_name);
        } else {
          console.log("rooms-list要素が見つかりません");
        }
      },

      handleRoomDeletion(data) {
        console.log("ルーム削除を処理:", data.room_name);
        
        // 削除されたルームを画面から除去
        const roomItem = document.getElementById(`room-${data.room_id}`);
        if (roomItem) {
          roomItem.remove();
          console.log("ルームアイテムを削除しました:", data.room_name);
          
          // ルームが全て削除された場合、「現在、ルームはありません。」メッセージを表示
          const roomsList = document.querySelector('.rooms-list');
          if (roomsList && roomsList.children.length === 0) {
            const noRoomsMessage = document.createElement('p');
            noRoomsMessage.className = 'no-rooms';
            noRoomsMessage.textContent = '現在、ルームはありません。';
            roomsList.appendChild(noRoomsMessage);
          }
        } else {
          console.log("削除対象のルームが見つかりません:", data.room_id);
        }
      },
    });
  }
});
