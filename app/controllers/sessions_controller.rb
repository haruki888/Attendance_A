class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase) #params[:session][:email]でユーザのcreate(post)の値を取り、
    if user && user.authenticate(params[:session][:password])     #find_byでemailが一致した場合ユーザに代入する
      log_in user                                                 #&&を使って、条件を2つ指定しています。
      redirect_to user                                            #user⇨userの中身があるかどうか
    else                                                          #user.authenticate⇨userに代入されたレコードのパスワードがポストした値と一致しているか
      flash.now[:danger] = '認証に失敗しました。'                 #パスワードが登録しているユーザー情報と一致していたらセッションにユーザーIDを登録しています。  
      render :new    #render→リクエストとは見なされないためにフラッシュが消えない。                                             
    end
  end
  
  def destroy
    log_out
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end
