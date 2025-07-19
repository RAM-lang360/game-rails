// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

// ハンバーガーメニューの動作
window.toggleUserPopup = function() {
  const popup = document.getElementById('userPopup');
  popup.classList.toggle('show');
}

// ポップアップ外をクリックしたら閉じる
document.addEventListener('click', function(event) {
  const popup = document.getElementById('userPopup');
  const hamburger = document.querySelector('.hamburger-menu');
  
  if (popup && !popup.contains(event.target) && !hamburger.contains(event.target)) {
    popup.classList.remove('show');
  }
});

// ルーム参加機能
window.joinRoom = function(roomName) {
  // URLパラメータでルーム名を渡してjoin_roomページに遷移
  const joinUrl = `/lobby/join_room?room_name=${encodeURIComponent(roomName)}`;
  window.location.href = joinUrl;
};
