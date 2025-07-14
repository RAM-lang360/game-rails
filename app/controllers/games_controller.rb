class GamesController < ApplicationController
  before_action :find_room

  def good_ans
    # ホストがゲーム開始パラメータ付きでアクセスした場合のみブロードキャスト
    if params[:start_game] == "true" && current_user.id == @room.host_id
      broadcast_game_start
    end

    puts "ルームID: #{@room.id} の朝までそれ正解ゲームを開始します"
  end

  def quiz_battle
    puts "ルームID: #{@room.id} のクイズバトルゲームを開始します"
  end

  def word_chain
    puts "ルームID: #{@room.id} のしりとりゲームを開始します"
  end

  private

  def find_room
    @room = Room.find(params[:id])
  end

  def broadcast_game_start
    ActionCable.server.broadcast(
      "navigation_room_#{@room.id}",
      {
        action: "redirect",
        url: good_ans_game_path(@room),
        game_type: "good_ans",
        message: "ホストが朝までそれ正解を開始しました。ゲーム画面に移動します。"
      }
    )

    puts "ルーム#{@room.id}の全ユーザーにgood_ansゲーム開始をブロードキャストしました"
  end
end
