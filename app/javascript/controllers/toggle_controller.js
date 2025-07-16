// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["content"] // HTMLから参照する要素の名前を定義

    connect() {
        // コントローラが接続されたときに実行
        // this.contentTarget.style.display = 'none'; // 必要であれば初期状態をJSで設定
    }

    async toggle() {
        try {
            const roomId = document.querySelector('[data-good-ans-id]')?.dataset.goodAnsId;
            console.log(`Toggle action triggered for room ID: ${roomId}`);

            const response = await fetch(`/games/${roomId}/draw`, {
                method: "POST",
                headers: {
                    "Accept": "application/json",
                    "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content // CSRFトークン
                }
            });
        } catch (error) {
            console.error("Error occurred while toggling content:", error);
        }
        this.contentTarget.classList.toggle("hidden");
    }
}