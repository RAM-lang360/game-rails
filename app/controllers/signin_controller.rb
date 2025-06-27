class SigninController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  def new
    @user=User.new
  end

  def create
    @user = User.new(user_paryams)
    if @user.save
      start_new_session_for @user # 登録後すぐにログインさせる
      redirect_to lobby_index_path, notice: "アカウントを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @user = User.new(user_paryams)
    @user.errors.add(:name, "は既に使用されています")
    render :new, status: :unprocessable_entity
  end

  def user_paryams
    params.permit(:name, :password)
  end
end
