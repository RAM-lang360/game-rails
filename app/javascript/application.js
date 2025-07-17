// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

document.addEventListener("turbo:before-stream-render", (event) => {
  console.log("--- turbo:before-stream-render イベント発火 ---");
  // ... (既存のログ)
  const templateElement = event.detail.newStream.templateElement;
  if (templateElement) {
    console.log("テンプレートの中身のHTML:", templateElement.innerHTML); // <-- これを追加
  }
});