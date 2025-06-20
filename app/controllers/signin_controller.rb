class SigninController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  def new
    @user=User.new
  end

  def create
    @user = User.new(user_paryams)
    if @user.save
      session[:user_id] = @user.id # 登録後すぐにログインさせる
      # redirect_to root_path, notice: "アカウントを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def user_paryams
    params.permit(:name, :password)
  end
end
