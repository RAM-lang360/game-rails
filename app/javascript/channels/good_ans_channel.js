import consumer from "channels/consumer"

document.addEventListener('turbo:load', () => {
  console.log("turbo:load イベントが発火しました。");

  // data-good-ans-id を持つ要素から roomId を取得
  const roomIdElement = document.querySelector('[data-good-ans-id]');
  const roomId = roomIdElement ? roomIdElement.dataset.goodAnsId : null;

  if (roomId) {
    console.log(`ルーム${roomId}のGoodAnsChannelに接続中...`);

    // サブスクリプションオブジェクトを保持する変数
    let goodAnsSubscription = null;

    // 既に同じチャンネルに接続していないかチェック
    // 既存のサブスクリプションを切断してから新しい接続を確立する
    // (これは turbo:load が複数回発火する可能性を考慮した一般的なプラクティス)
    if (consumer.subscriptions.findAll("GoodAnsChannel").length > 0) {
      console.log("既存のGoodAnsChannelサブスクリプションを破棄します。");
      consumer.subscriptions.findAll("GoodAnsChannel").forEach(sub => sub.unsubscribe());
    }

    goodAnsSubscription = consumer.subscriptions.create({ channel: "GoodAnsChannel", room_id: roomId }, {
      connected() {
        console.log(`ルーム${roomId}のGoodAnsChannelに接続しました`);
      },

      disconnected() {
        console.log(`ルーム${roomId}のGoodAnsChannelから切断されました`);
      },

      received(data) {
        console.log("GoodAnsChannelからデータを受信しました:", data);

        if (data.action === "draw") {
          const themeElement = document.getElementById("theme"); // themeId より themeElement が適切
          if (themeElement) {
            themeElement.innerHTML = data.theme;
            console.log("お題を更新しました:", data.theme);
          } else {
            console.warn("ID 'theme' を持つ要素が見つかりませんでした。");
          }
        }
        // 他のアクション（例: 'answer_received'）もここに追加可能
        if (data.action === "answer") {
          // 回答を表示するロジック
          console.log("回答を受信しました:", data.user_name, data.answer);
          const answerElement = document.getElementById("answers");
          if (answerElement) {
            const newAnswer = document.createElement("div");
            newAnswer.textContent = `${data.user_name}: ${data.answer}`;
            answerElement.appendChild(newAnswer);
            console.log("回答を表示しました:", data.user_name, data.answer);
          } else {
            console.warn("ID 'answers' を持つ要素が見つかりませんでした。");
          }
        }
      }
    });
  } else {
    console.warn("data-good-ans-id を持つ要素が見つからなかったため、GoodAnsChannelに接続しません。");
  }
});