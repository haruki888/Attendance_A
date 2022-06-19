class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])  #params[:id]は/users/1の1に置き換わる
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  private #user_paramsメソッドは、Usersコントローラーの内部でのみ実行されます。
          #Web経由で外部のユーザーが知る必要は無いため、次に記すようにRubyのprivateキーワードを用いて
          #外部からは使用できないようにします
          
  def user_params #Strong Parameters
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end