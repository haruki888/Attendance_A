class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)       #params[:session][:email]でユーザのcreate(post)の値を取り、
    if user && user.authenticate(params[:session][:password])           #find_byでemailが一致した場合ユーザに代入する
      log_in user                                                       #&&を使って、条件を2つ指定しています。    
      params[:session][:remember_me] == '1'? remember(user):forget(user)#user⇨userの中身があるかどうか
      redirect_to user                                                  #user.authenticate⇨userに代入されたレコードのパスワードがポストした値と一致しているか
    else                                                                #パスワードが登録しているユーザー情報と一致していたらセッションにユーザーIDを登録しています。  
      flash.now[:danger] = '認証に失敗しました。'                 
      render :new    #render→リクエストとは見なされないためにフラッシュが消えない。                                             
    end
  end
  
  def destroy
    # ログイン中の場合のみログアウト処理を実行します。
    log_out if logged_in? 
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end     